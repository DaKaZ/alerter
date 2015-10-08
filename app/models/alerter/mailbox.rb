class Alerter::Mailbox
  attr_reader :notifiable

  #Initializer method
  def initialize(notifiable)
    @notifiable = notifiable
  end

  #Returns the notifications for the messageable
  def notifications(options = {})
    #:type => nil is a hack not to give Messages as Notifications
    notifs = Alerter::Message.recipient(@notifiable).where(:type => nil).order("alerter_messages.created_at DESC")
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
  def messages(options = {})
    messages = get_messages(options[:mailbox_type])

    if options[:read] == false || options[:unread]
      messages = messages.unread(notifiable)
    end

    messages
  end

  #Returns the messages in the inbox of notifiable
  #
  #Same as conversations({:mailbox_type => 'inbox'})
  def inbox(options={})
    options = options.merge(:mailbox_type => 'inbox')
    messages(options)
  end


  #Returns all the receipts of notifiable from Messages
  def receipts(options = {})
    Alerter::Receipt.where(options).recipient(notifiable)
  end


  private

  def get_messages(mailbox)
    case mailbox
      when 'inbox'
        Alerter::Message.inbox(notifiable)
    end

  end


end