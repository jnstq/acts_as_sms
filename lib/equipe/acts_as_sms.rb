require "yaml"
require "httparty"

module Equipe
  module ActsAsSms
    FIELDS_WITH_DEFAULT_VALUES = [:message_type, :originator_type, :originator]
    def self.included(base)
      base.extend ActMethods
    end

    module ActMethods
      def acts_as_sms(options = {})
        options.reverse_merge! :allow_concat => 6, :message_type => 'text', :originator_type => 'numeric'
        unless included_modules.include?(Equipe::ActsAsSms::InstanceMethods)
          class_inheritable_hash :acts_as_sms_options
          self.acts_as_sms_options = {}
          extend ClassMethods
          include InstanceMethods
          include HTTParty
          class_eval do
            validation_for_sms_message
            has_many :delivery_receipts
          end
          build_delivery_receipt_model(self.name)
        end
        acts_as_sms_options.update(options)
      end
      private
      def build_delivery_receipt_model(base_class_name)
        unless defined?(DeliveryReceipt)
          Object.const_set(:DeliveryReceipt, Class.new(ActiveRecord::Base)).class_eval do
            set_table_name :delivery_receipts
            belongs_to :message, :class_name => "#{base_class_name}"
          end
        end
      end
      def validation_for_sms_message
        validates_inclusion_of :originator_type, :in => %w[numeric shortcode alpha], :allow_blank => false, :allow_nil => false
        validates_length_of :originator, :within => 1..15, :if => Proc.new{|sms| sms.originator_type_is_numeric? || sms.originator_type_is_shortcode?}
        validates_format_of :originator, :with => /^[^00]\d+$/, :if => :originator_type_is_numeric?
        validates_format_of :originator, :with => /^[a-zA-Z0-9]{1,11}$/, :if => :originator_type_is_alpha?
        validates_format_of :destination, :with => /^[00]{2}[^0]+\d+$/
      end
    end

    module ClassMethods
      def sms_configuration
        filename = "#{Rails.root}/config/sms.yml"
        fail "Configuration file not found in config/sms.yml" unless File.exist?(filename)
        @sms_configuration ||= File.open(filename) { |file| YAML.load(file)[Rails.env] }
      end
    end

    module InstanceMethods

      %w[numeric shortcode alpha].each do |ot|
        define_method("originator_type_is_#{ot}?") do
          originator_type.to_s == ot
        end
      end
      
      def sent?
        !delivery_receipts.empty?
      end

      def send_message
        if save
          response = self.class.post(send_sms_url, {:query => extract_options_for_sms})
          if response =~ /^(OK|Error):\s{1}(.*)$/
            case :"#{$1.downcase}"
            when :ok
              save_tracking_ids($2.split(/,/))
            when :error
              fail "Error message from gateway: #{$2}"
            end
          else
            fail "Unknown response from gateway: #{response}"
          end
        end
      end

      def after_initialize
        Equipe::ActsAsSms::FIELDS_WITH_DEFAULT_VALUES.each do |key|
          send(:"#{key}=", acts_as_sms_options[key]) if send(key).nil? && acts_as_sms_options.has_key?(key)
        end
      end
      
      def max_length
        acts_as_sms_options[:allow_concat] == 1 ? 160 : 153 * 6
      end

      protected

      def validate
        errors.add(:body, "too long") if body.to_s.length > max_length
      end
      
      private
      
      def save_tracking_ids(*tracking_ids)
        tracking_ids.each do |tracking_id|
          delivery_receipts.create!(:status => 'sent', :tracking_id => tracking_id)
        end        
      end
      
      def send_sms_url
        self.class.sms_configuration["sms_url"]
      end
      
      def extract_options_for_sms
        { 
          :username => self.class.sms_configuration["username"],
          :password => self.class.sms_configuration["password"],
          :destination => destination,
          :text => body,
          :originatortype => originator_type,
          :originator => originator,
          :type => message_type,
          :allowconcat => acts_as_sms_options[:allow_concat]
        }
      end

    end

  end
end

unless ActiveRecord::Base.included_modules.include?(Equipe::ActsAsSms)
  ActiveRecord::Base.send(:include, Equipe::ActsAsSms)
end
