class Alerter::Message < ActiveRecord::Base
  self.table_name = :alerter_messages

  attr_accessor :recipients
  attr_accessible :message, :subject, :global, :expires if Alerter.protected_attributes?

  belongs_to :sender, :polymorphic => :true
  belongs_to :notified_object, :polymorphic => :true
  belongs_to :notification_type
  has_many :receipts, :dependent => :destroy, :class_name => "Alerter::Receipt"

  validates :notification_type, :presence => true
  validates :short_msg,    :presence => true,
            :length => { :maximum => Alerter.short_msg_length }
  validates :long_msg,    :presence => true,
            :length => { :maximum => Alerter.long_msg_length }




  scope :receipts, lambda { |recipient|
                    joins(:receipts).where('Alerter_receipts.receiver_id' => recipient.id,'Alerter_receipts.receiver_type' => recipient.class.base_class.to_s)
                  }

  scope :inbox, lambda {|recipient|
                receipts(recipient).merge(Alerter::Receipt.inbox.not_trash.not_deleted)
              }
  scope :sentbox, lambda {|recipient|
                  receipts(recipient).merge(Alerter::Receipt.sentbox.not_trash.not_deleted)
                }

  scope :unread,  lambda {
                 joins(:receipts).where('Alerter_receipts.is_read' => false)
               }
  scope :global, lambda { where(:global => true) }
  scope :expired, lambda { where("Alerter_notifications.expires < ?", Time.now) }
  scope :unexpired, lambda {
                    where("Alerter_notifications.expires is NULL OR Alerter_notifications.expires > ?", Time.now)
                  }

  class << self
    #Sends a Notification to all the recipients
    # def notify_all(recipients, short_msg, long_msg, obj = nil, sanitize_text = true, notification_code=nil, sender=nil)
    #   notification = Alerter::MessageBuilder.new({
    #                                                         :recipients        => recipients,
    #                                                         :short_msg         => short_msg,
    #                                                         :long_msg          => long_msg,
    #                                                         :notified_object   => obj,
    #                                                         :notification_code => notification_code,
    #                                                         :sender            => sender
    #                                                     }).build
    #
    #   notification.deliver sanitize_text
    # end

    #Takes a +Receipt+ or an +Array+ of them and returns +true+ if the delivery was
    #successful or +false+ if some error raised
    def successful_delivery? receipts
      case receipts
        when Alerter::Receipt
          receipts.valid?
        when Array
          receipts.all?(&:valid?)
        else
          false
      end
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
  #Use Alerter::Models::Message.notify and Notification.notify_all instead.
  def deliver(should_clean = true)
    clean if should_clean
    temp_receipts = recipients.map { |r| build_receipt(r, 'inbox', false) }
    if temp_receipts.all?(&:valid?)
      temp_receipts.each(&:save!)   #Save receipts
      #Alerter::MailDispatcher.new(self, recipients).call
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
                                      :receiver     => receiver,
                                      :is_read      => is_read
                                  }).build
  end

end