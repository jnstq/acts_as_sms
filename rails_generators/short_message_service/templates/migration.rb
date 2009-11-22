class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= short_message_table_name %> do |t|
      t.string :destination
      t.integer :price 
      t.text :body
      t.string :originator
      t.string :originator_type
      t.string :message_type
      t.timestamps
    end
    create_table :<%= delivery_receipt_table_name %> do |t|
      t.references :<%= short_message_model_name.underscore %>
      t.string :tracking_id, :limit => 32
      t.string :status, :limit => 20
      t.timestamps
    end
    add_index :<%= delivery_receipt_table_name %>, :<%= "#{short_message_model_name.underscore}_id" %>
    add_index :<%= delivery_receipt_table_name %>, :tracking_id
    create_table :incoming_short_messages do |t|
      t.string :country, :limit => 2
      t.string :operator, :limit => 20
      t.string :shortcode, :limit => 15
      t.string :sender
      t.text :text
      t.string :session_id, :limit => 40
    end
  end

  def self.down
    remove_index :<%= delivery_receipt_table_name %>, :<%= "#{short_message_model_name.underscore}_id" %>
    remove_index :<%= delivery_receipt_table_name %>, :tracking_id
    drop_table :<%= short_message_table_name %>
    drop_table :<%= delivery_receipt_table_name %>
    drop_table :incoming_short_messages
  end
end