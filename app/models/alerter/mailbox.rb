class Alerter::Mailbox
  attr_reader :notifiable

  #Initializer method
  def initialize(notifiable)
    @notifiable = notifiable
  end

  #Returns the notifications for the messageable
  def notifications(options = {})
    #:type => nil is a hack not to give Messages as Notifications
    notifs = Alerter::Notification.recipient(messageable).where(:type => nil).order("Alerter_notifications.created_at DESC")
    if options[:read] == false || options[:unread]
      notifs = notifs.unread
    end

    notifs
  end

  #Returns the conversations for the messageable
  #
  #Options
  #
  #* :mailbox_type
  #  * "inbox"
  #  * "sentbox"
  #  * "trash"
  #
  #* :read=false
  #* :unread=true
  #
  def conversations(options = {})
    messages = get_messages(options[:mailbox_type])

    if options[:read] == false || options[:unread]
      messages = messages.unread(notifiable)
    end

    conv
  end

  #Returns the messages in the inbox of notifiable
  #
  #Same as conversations({:mailbox_type => 'inbox'})
  def inbox(options={})
    options = options.merge(:mailbox_type => 'inbox')
    conversations(options)
  end

  #Returns the messages in the sentbox of notifiable
  #
  #Same as conversations({:mailbox_type => 'sentbox'})
  def sentbox(options={})
    options = options.merge(:mailbox_type => 'sentbox')
    conversations(options)
  end

  #Returns the conversations in the trash of notifiable
  #
  #Same as conversations({:mailbox_type => 'trash'})
  def trash(options={})
    options = options.merge(:mailbox_type => 'trash')
    conversations(options)
  end

  #Returns all the receipts of notifiable from Messages
  def receipts(options = {})
    Alerter::Receipt.where(options).recipient(notifiable)
  end


  private

  def get_messages(mailbox)
    case mailbox
      when 'inbox'
        Alerter::Conversation.inbox(notifiable)
      when 'sentbox'
        Alerter::Conversation.sentbox(notifiable)
    end

  end


end