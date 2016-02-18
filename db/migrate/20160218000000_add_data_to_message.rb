class AddDataToMessage < ActiveRecord::Migration
  def change
    add_column :alerter_messages, :data, :text
  end
end
