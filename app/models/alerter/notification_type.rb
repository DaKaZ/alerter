class Alerter::NotificationType < ActiveRecord::Base
  self.table_name = :alerter_notification_types


  attr_accessible :name if Alerter.protected_attributes?

  belongs_to :message
  has_many :preferences
  before_save :check_notification_type


  validates_uniqueness_of :name

  protected
  def check_notification_type
    Alerter.available_notification_types.include?(self.name)
  end

end