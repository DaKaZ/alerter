class Alerter::Preference < ActiveRecord::Base
  self.table_name = :alerter_preferences
  attr_accessible :alert_methods if Alerter.protected_attributes?

  belongs_to :notifiable, :polymorphic => :true
  belongs_to :notification_type

  validates :notification_type_id, uniqueness: { scope: :notifiable_id }
  validates_presence_of :notification_type_id

  before_validation do
    self.alert_methods.reject!{|x| x.blank?}
  end

  serialize :alert_methods, Array

  validate :alert_methods do
    unless self.methods.nil? || self.alert_methods.count == 0 || (self.alert_methods - Alerter::available_notification_methods).empty?
      errors.add(:alert_methods, "Must be only: #{Alerter::available_notification_methods.join(", ")}")
    end
  end



end