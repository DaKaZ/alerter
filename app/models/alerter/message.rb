class Alerter::Message < ActiveRecord::Base
  self.table_name = :alerter_messages

  attr_accessor :recipients
  attr_accessible :message, :subject, :global, :expires if Alerter.protected_attributes?

  belongs_to :notified_object, :polymorphic => :true
  belongs_to :notification_type
  has_many :receipts, :dependent => :destroy, :class_name => "Alerter::Receipt"

  validates :notification_type, :presence => true
  validates :short_msg, :presence => true,
            :length => {:maximum => Alerter.short_msg_length}
  validates :long_msg, :presence => true,
            :length => {:maximum => Alerter.long_msg_length}

  scope :receipts, lambda { |recipient|
    joins(:receipts).where('alerter_receipts.receiver_id' => recipient.id, 'alerter_receipts.receiver_type' => recipient.class.base_class.to_s)
  }

  scope :inbox, lambda { |recipient|
    receipts(recipient).merge(Alerter::Receipt.inbox.not_deleted)
  }

  scope :trash, lambda { |recipient|
    receipts(recipient).merge(Alerter::Receipt.deleted)
  }

  scope :unread, lambda {
    joins(:receipts).where('alerter_receipts.is_read' => false)
  }
  scope :read, lambda {
    joins(:receipts).where('alerter_receipts.is_read' => true)
  }
  scope :global, lambda {
    where(:global => true)
  }
  scope :expired, lambda {
    where("alerter_messages.expires < ?", Time.now)
  }
  scope :unexpired, lambda {
    where("alerter_messages.expires is NULL OR alerter_messages.expires > ?", Time.now)
  }

  class << self
    def message_all(recipients, short_msg, long_msg, notification_type_name, sanitize_text = true, data = '', push_data = '')
      message = Alerter::MessageBuilder.new({
                                                recipients: recipients,
                                                short_msg: short_msg,
                                                long_msg: long_msg,
                                                data: data.to_s,
                                                push_data: push_data.to_s,
                                                notification_type: Alerter::NotificationType.find_or_create_by(name: notification_type_name),
                                            }).build
      message.save!
      message.deliver sanitize_text
    end
  end

  def expired?
    expires.present? && (expires < Time.now)
  end

  def expire!
    unless expired?
      expire
      save
    end
  end

  def expire
    unless expired?
      self.expires = Time.now - 1.second
    end
  end

  #Delivers a Notification. USE NOT RECOMENDED.
  #Use Alerter::Models::Message.message and Notification.message_all instead.
  def deliver(should_clean = true)
    clean if should_clean
    temp_receipts = recipients.map { |r| build_receipt(r, 'inbox', false) }
    if temp_receipts.all?(&:valid?)
      temp_receipts.each(&:save!) #Save receipts
      Alerter::MessageDispatcher.new(self, recipients).call
      #self.recipients = nil
    end

    return temp_receipts if temp_receipts.size > 1
    temp_receipts.first
  end

  #Returns the recipients of the Notification
  def recipients
    return Array.wrap(@recipients) unless @recipients.blank?
    @recipients = receipts.map { |receipt| receipt.receiver }
  end

  #Returns the receipt for the participant
  def receipt_for(participant)
    #Alerter::Receipt.notification(self).recipient(participant)
    self.receipts.recipient(participant)
  end

  #Returns the receipt for the participant. Alias for receipt_for(participant)
  def receipts_for(participant)
    receipt_for(participant)
  end

  #Returns if the participant have read the Notification
  def is_unread?(participant)
    return false if participant.nil?
    !receipt_for(participant).first.is_read
  end

  def is_read?(participant)
    !is_unread?(participant)
  end

  #Returns if the participant have deleted the Notification
  def is_deleted?(participant)
    return false if participant.nil?
    return receipt_for(participant).first.deleted
  end

  #Mark the notification as read
  def mark_as_read(participant)
    return if participant.nil?
    receipt_for(participant).mark_as_read
  end

  #Mark the notification as unread
  def mark_as_unread(participant)
    return if participant.nil?
    receipt_for(participant).mark_as_unread
  end


  #Mark the notification as deleted for one of the participant
  def mark_as_deleted(participant)
    return if participant.nil?
    return receipt_for(participant).mark_as_deleted
  end

  #Mark the notification as not deleted for one of the participant
  def mark_as_not_deleted(participant)
    return if participant.nil?
    return receipt_for(participant).mark_as_not_deleted
  end

  #Sanitizes the body and subject
  def clean
    self.short_msg = sanitize(short_msg)
    self.long_msg = sanitize(long_msg)
  end


  def sanitize(text)
    ::Alerter::Cleaner.instance.sanitize(text)
  end

  private

  def build_receipt(receiver, mailbox_type, is_read = false)
    Alerter::ReceiptBuilder.new({
                                    :message => self,
                                    :mailbox_type => mailbox_type,
                                    :receiver => receiver,
                                    :is_read => is_read
                                }).build
  end

end