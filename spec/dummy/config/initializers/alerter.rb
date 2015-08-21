Alerter.setup do |config|

  #Configures the default from for emails sent for Messages
  config.default_from = "no-reply@alert.com"

  #Configures the default subject line (only used in emails)
  config.default_subject = "Alerter: you have a new message!"

  #Configures the methods needed by alerter to get information about the model its attached to
  config.email_method = :email
  config.name_method = :name

  #Configures the array of available (supported) notification methods
  # Available choices are: none email push sms twitter
  config.available_notification_methods = %w( none email push sms twitter )

  #Configures maximum length of the message
  config.short_msg_length = 144 # twitter support
  config.long_msg_length = 2048
end
