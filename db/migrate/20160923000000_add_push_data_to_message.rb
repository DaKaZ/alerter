class AddPushDataToMessage < ActiveRecord::Migration
  def change
    add_column :alerter_messages, :push_data, :text
  end
end
