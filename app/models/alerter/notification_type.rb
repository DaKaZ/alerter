class Alerter::NotificationType < ActiveRecord::Base
  self.table_name = :alerter_notification_types


  attr_accessible :name if Alerter.protected_attributes?

  belongs_to :message
  has_many :preferences


  validates_uniqueness_of :name

end