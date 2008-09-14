class CreateDeliveryReceipts < ActiveRecord::Migration
  def self.up
    create_table :delivery_receipts do |t|
      t.references :message
      t.string :tracking_id, :limit => 32
      t.string :status, :limit => 20
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_receipts
  end
end