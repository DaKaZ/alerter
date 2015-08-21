class Alerter::Prefrences < ActiveRecord::Base
  self.table_name = :alerter_prefrences
  attr_accessible :methods if Alerter.protected_attributes?

  belongs_to :notifiable, :polymorphic => :true
  belongs_to :notification_type

  serialize :methods, Array

  validate :methods do |methods|
    unless (methods - Alerter.available_notification_methods).empty?
      errors.add(:methods, "Must be only: #{Alerter.available_notification_methods.join(", ")}")
    end
  end


end