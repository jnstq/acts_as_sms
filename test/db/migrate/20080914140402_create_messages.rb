class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :destination
      t.text :body
      t.string :originator_type
      t.string :originator
      t.string :message_type
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end