require File.expand_path(File.dirname(__FILE__) + "/lib/insert_routes.rb")
class ShortMessageServiceGenerator < Rails::Generator::Base
  attr_accessor :short_message_model_name, :delivery_receipt_model_name, :migration_name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if @args.empty?    
    @short_message_model_name = @args[0].camelcase
    @delivery_receipt_model_name = @args[1].camelcase
  end
  
  def short_message_table_name
    @short_message_model_name.pluralize.underscore
  end
  
  def delivery_receipt_table_name
    @delivery_receipt_model_name.pluralize.underscore
  end
  
  def standard_delivery_receipt_model_name?
    @delivery_receipt_model_name == "DeliveryReceipt"
  end
  
  def standard_short_message_model_name?
    @short_message_model_name == "ShortMessage"
  end
  
  def manifest
    recorded_session = record do |m|
      unless options[:skip_model]
        m.directory "app/models"
        m.template "short_message.rb", "app/models/#{@short_message_model_name.underscore}.rb"
        m.template "delivery_receipt.rb", "app/models/#{@delivery_receipt_model_name.underscore}.rb"
        m.template "incoming_short_message.rb", "app/models/incoming_short_message.rb"
      end
      unless options[:skip_controller]
        m.directory "app/controllers"
        m.template "short_messages_controller.rb", "app/controllers/#{short_message_table_name}_controller.rb"
        m.template "delivery_receipts_controller.rb", "app/controllers/#{delivery_receipt_table_name}_controller.rb"
        m.template "incoming_short_messages_controller.rb", "app/controllers/incoming_short_messages_controller.rb"
      end
      unless options[:skip_views]
        m.directory "app/views/#{short_message_table_name}"
        m.template "index.html.erb", "app/views/#{short_message_table_name}/index.html.erb"
        m.template "new.html.erb", "app/views/#{short_message_table_name}/new.html.erb"
      end
      unless options[:skip_config]
        m.directory "config"
        m.template "short_message.yml", "config/short_message.yml"
      end
      unless options[:skip_routes]        
        m.route_resources short_message_model_name.pluralize.underscore
        m.route_name('delivery_report', 'delivery_receipts/report',  :controller => delivery_receipt_model_name.pluralize.underscore, :action => 'report')
        m.route_name('incoming_sms', 'incoming_short_messages/incoming', :controller => 'incoming_short_messages', :action => 'incoming')
      end
      unless options[:skip_migration]
        @migration_name = "Create#{@short_message_model_name}And#{@delivery_receipt_model_name}"
        m.migration_template "migration.rb", "db/migrate", :migration_file_name => migration_name.underscore
      end
    end
    
    
    # Post-install notes
    action = File.basename($0) # grok the action from './script/generate' or whatever
    case action
    when "generate"
      puts "=" * 70  
      puts "Generateing models and controllers for short message service"
      puts "through Cellsynt's SMS gateway HTTP interface"
      puts "\n"
      puts " Edit authentication settings for the\n sms gateway in config/short_message.yml."
      puts "\n"
      puts " Login to sms.cellsynt.net, under integration set delivery receipt url"
      puts " to http://www.yourdomain.com/delivery_receipts/report"
      puts "\n"
      puts " run rake db:migrate to run the migration for message table\n and delivery receipt table"
      puts "\n"
      puts "Restart your server and browse to /short_messages you should \nnow be able to send sms"
      puts "-" * 70      
    end

    recorded_session
  end
end
