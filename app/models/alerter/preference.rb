class Alerter::Preference < ActiveRecord::Base
  self.table_name = :alerter_preferences
  attr_accessible :methods if Alerter.protected_attributes?

  belongs_to :notifiable, :polymorphic => :true
  belongs_to :notification_type

  validates :alerter_notification_types_id, uniqueness: { scope: :notifiable_id }

  serialize :methods, Array

  validate :methods do
    unless self.methods.nil? || self.methods.count == 0 || (self.methods - Alerter::available_notification_methods).empty?
      errors.add(:methods, "Must be only: #{Alerter::available_notification_methods.join(", ")}")
    end
  end


end