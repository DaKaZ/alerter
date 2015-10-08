class CreateAlerter < ActiveRecord::Migration
  def self.up
    #Tables

    #Receipts
    create_table :alerter_receipts do |t|
      t.references :receiver, :polymorphic => true
      t.column :message_id, :integer, :null => false
      t.column :is_read, :boolean, :default => false
      t.column :trashed, :boolean, :default => false
      t.column :deleted, :boolean, :default => false
      t.column :mailbox_type, :string, :limit => 25
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
    #Messages
    create_table :alerter_messages do |t|
      t.column :type, :string
      t.column :short_msg, :string, :default => ""
      t.column :long_msg, :text, :default => ""
      t.column :draft, :boolean, :default => false
      t.string :notification_code, :default => nil
      t.references :notified_object, :polymorphic => true
      t.references :notification_type
      t.column :attachment, :string
      t.column :updated_at, :datetime, :null => false
      t.column :created_at, :datetime, :null => false
      t.boolean :global, default: false
      t.datetime :expires
    end

    #Notification Types
    create_table :alerter_notification_types do |t|
      t.column :name, :string, :null => :false
    end

    #preferences
    create_table :alerter_preferences do |t|
      t.references :alerter_notification_types
      t.references :notifiable, :polymorphic => true
      t.column :methods, :text
    end


    #Indexes
    #Receipts
    add_index "alerter_receipts","message_id"

    #Foreign keys
    #Conversations
    #Receipts
    add_foreign_key "alerter_receipts", "alerter_messages", :name => "receipts_on_message_id", :column => "message_id"

  end

  def self.down
    #Tables
    remove_foreign_key "alerter_receipts", :name => "receipts_on_message_id"

    #Indexes
    drop_table :alerter_receipts
    drop_table :alerter_messages
    drop_table :alerter_notification_types
    drop_table :alerter_preferences

  end
end