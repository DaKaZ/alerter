class Alerter::NotificationType < ActiveRecord::Base
  self.table_name = :alerter_notification_type


  attr_accessible :name, :expires if Alerter.protected_attributes?

  belongs_to :message
  has_many :preferences


  validates_uniqueness_of :name

end