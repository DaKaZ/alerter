require "alerter/version"

module Alerter
  module Models
    autoload :Notifiable, 'alerter/models/notifiable'
  end

  # Default from address for email notifications
  mattr_accessor :default_from
  @@default_from = "no-reply@alerter.com"

  # default subject to use on emails only
  mattr_accessor :default_subject
  @@default_from = "Alerter: you have a new message!"

  # method used to retrieve the recipient's name
  mattr_accessor :name_method
  @@name_method = :name

  # method used to retrieve the recipient's email
  mattr_accessor :email_method
  @@email_method = :email

  mattr_accessor :short_msg_length
  @@short_msg_length = 144

  mattr_accessor :long_msg_length
  @@long_msg_length = 512

  mattr_accessor :mailer_wants_array
  @@mailer_wants_array = false

  # array of available (supported) notification types
  mattr_accessor :available_notification_types
  @@available_notification_types = %w( info warning error action )

  # array of available (supported) notification methods
  mattr_accessor :available_notification_methods
  @@available_notification_methods = %w( none email ios_push android_push sms twitter )

  # the chosen notification method for this object
  mattr_accessor :notification_method
  @@notification_method = %w( none )

  # Base url to use in messages
  @@root_url = 'www.alerter.com'

  mattr_accessor :email_message_mailer
  mattr_accessor :custom_email_delivery_proc
  mattr_accessor :sms_message_mailer
  mattr_accessor :custom_sms_delivery_proc
  mattr_accessor :push_message_mailer
  mattr_accessor :custom_push_delivery_proc
  mattr_accessor :root_url

  class << self
    def setup
      yield self
    end

    def protected_attributes?
      Rails.version < '4' || defined?(ProtectedAttributes)
    end
  end
end

# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it
require 'alerter/engine'
require 'alerter/cleaner'
require 'alerter/message_dispatcher'