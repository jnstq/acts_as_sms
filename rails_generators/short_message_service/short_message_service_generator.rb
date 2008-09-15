class ShortMessageServiceGenerator < Rails::Generator::Base
  attr_accessor :short_message_model_name, :delivery_receipt_model_name, :migration_name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if @args.empty?    
    @short_message_model_name = @args[0].camelcase
    @delivery_receipt_model_name = @args[1].camelcase

    puts "runtime_args: #{runtime_args.inspect}"
    puts "runtime_options: #{runtime_options.inspect}"
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
    record do |m|
      unless options[:skip_model]
        m.directory "app/models"
        m.template "short_message.rb", "app/models/#{@short_message_model_name.underscore}.rb"
        m.template "delivery_receipt.rb", "app/models/#{@delivery_receipt_model_name.underscore}.rb"
      end
      unless options[:skip_migration]
        @migration_name = "Create#{@short_message_model_name}And#{@delivery_receipt_model_name}"
        m.migration_template "migration.rb", "db/migrate", :migration_file_name => migration_name.underscore
      end
      unless options[:skip_controller]
        m.directory "app/controllers"
        m.template "short_messages_controller.rb", "app/controllers/#{short_message_table_name}_controller.rb"
        m.template "delivery_receipts_controller.rb.rb", "app/controllers/#{delivery_receipt_table_name}_controller.rb"
      end
    end
  end
end
