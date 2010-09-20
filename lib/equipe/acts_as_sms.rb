require "yaml"
require "httparty"

module Equipe
  module ActsAsSms
    class GatewayError < StandardError; end
    FIELDS_WITH_DEFAULT_VALUES = [:message_type, :originator_type, :originator]

    def self.included(base)
      base.extend ActMethods
    end

    module ActMethods

      def acts_as_sms(options = {})
        options.reverse_merge! :allow_concat => 6, :message_type => 'text', :originator_type => 'alpha', :delivery_receipt_class_name => "DeliveryReceipt"
        unless included_modules.include?(Equipe::ActsAsSms::InstanceMethods)
          class_inheritable_hash :acts_as_sms_options
          self.acts_as_sms_options = {}
          extend ClassMethods
          include InstanceMethods
          include HTTParty
          class_eval do
            validation_for_sms_message
            has_many          :delivery_receipts, :class_name => options[:delivery_receipt_class_name]
            alias_attribute   :session_id, :destination
            after_initialize  :assign_default_values
          end
        end
        acts_as_sms_options.update(options)
      end

      private

      def validation_for_sms_message
        validates_inclusion_of :originator_type, :in => %w[numeric shortcode alpha], :allow_blank => false, :allow_nil => false, :unless => :price?
        validates_length_of :originator, :within => 1..15, :if => Proc.new{|sms| sms.originator_type_is_numeric? || sms.originator_type_is_shortcode?}
        validates_format_of :originator, :with => /^[^00]\d+$/, :if => :originator_type_is_numeric?
        validates_format_of :originator, :with => /^[a-zA-Z0-9]{1,11}$/, :if => :originator_type_is_alpha?
        validates_format_of :destination, :with => /^[00]{2}[^0]+\d+$/, :unless => :price?
        validates_presence_of :body
      end
    end

    module ClassMethods

      def sms_configuration
        filename = "#{Rails.root}/config/short_message.yml"
        fail "Configuration file not found in config/short_message.yml" unless File.exist?(filename)
        @sms_configuration ||= File.open(filename) { |file| YAML.load(file)[Rails.env] }
      end

    end

    module InstanceMethods

      %w[numeric shortcode alpha].each do |ot|
        define_method("originator_type_is_#{ot}?") do
          originator_type.to_s == ot
        end
      end

      def sms_configuration
        self.class.sms_configuration
      end

      def sent?
        !delivery_receipts.empty?
      end

      def delivered?
        delivery_receipts.all? {|report| report.status == 'delivered' }
      end

      def buffered?
        delivery_receipts.any? {|report| report.status == 'buffered' }
      end

      def failed?
        delivery_receipts.any? {|report| report.status == 'failed' }
      end

      def send_message
        if save
          response = perform_sms_post.strip
          if response =~ /(OK|ERROR):\s*(\S+)/i
            case $1.downcase
            when 'ok'
              save_tracking_ids($2.split(/,/))
            when 'error'
              raise GatewayError, $2
            end
          else
            raise GatewayError, "Unknown response: #{response}"
          end
        end
      end

      def assign_default_values
        return unless new_record?
        Equipe::ActsAsSms::FIELDS_WITH_DEFAULT_VALUES.each do |key|
          send(:"#{key}=", acts_as_sms_options[key]) if send(key).nil? && acts_as_sms_options.has_key?(key)
        end
      end

      def max_length
        acts_as_sms_options[:allow_concat] == 1 ? 160 : 153 * 6
      end

      def premium_sms?
        price?
      end

      def send_sms_url
        sms_configuration["#{'p' if premium_sms?}sms_url"]
      end

      def extract_options_for_sms
        returning options = {} do
          options[:username] = sms_configuration["username"]
          options[:password] = sms_configuration["password"]
          options[:destination] = destination unless premium_sms?
          options[:sessionid] = destination if premium_sms?
          options[:price] = price if premium_sms?
          options[:text] = body
          options[:originatortype] = originator_type unless premium_sms?
          options[:originator] = originator unless premium_sms?
          options[:type] = message_type unless premium_sms?
          options[:allowconcat] = acts_as_sms_options[:allow_concat] unless premium_sms?
        end
      end

      protected

      def validate
        errors.add(:body, "too long") if body.to_s.length > max_length
      end

      private

      def perform_sms_post
        self.class.post(send_sms_url, {:query => extract_options_for_sms})
      end

      def sms_url
        sms_configuration["sms_url"]
      end

      def premium_sms_url
        sms_configuration["psms_url"]
      end

      def save_tracking_ids(*tracking_ids)
        [tracking_ids].flatten.each do |tracking_id|
          delivery_receipts.create!(:status => 'sent', :tracking_id => tracking_id)
        end
      end

    end

  end
end
