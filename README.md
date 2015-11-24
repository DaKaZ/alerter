# Alerter

### This is ALPHA software 

We are still building out the mailers for everything except email...

## Overview

Alerter is a Rails gem for managing notifications within a standard Rails app.  Notifications are getting more complex
as applications now typically have multiple faces (web, mobile, social, etc) and users are requesting varying 
delivery methods for notifications (in-app, mobile push, email, text, social, etc).

Alter is largely derived from the outstanding Mailboxer app (https://github.com/mailboxer/mailboxer) but solving a 
very different problem: Notifications

Alerter provides 4 basic functions:
* Extend your user object with acts-as-notifiable
* Manage multiple Notification Types (these are application specific, ex: Billing, Support, Sales, Achievement, etc)
* Send and track delivery state for the notification providing a full audit history
* Provide notification preferences for users
  * Allow users to specify which methods (email, text, none, etc) they would like be notified on for different Notification Types


We need help with testing and documention, please jump in!

## Installation

Add this line to your application's Gemfile:

    gem 'rails-alerter'

And then execute:

    $ bundle install

Run the install script

    $ rails g alerter:install
    
Migrate the DB
    
    $ rake db:migrate
    
Generate your own email templates

    $ rails g alerter:views

In your model:

    class User < ActiveRecord::Base
      acts_as_notifiable
    end
    
## Usage

Alerter uses a `Alerter::Message` object that requires a short_msg and long_msg to accomidate different delivery
platforms.  You can configure the maximum length of these in the initializer:

     Alerter.setup do |config|
       config.short_msg_length = 144 # Up to String length for your DB
       config.long_msg_length  = 512 # Any length you want
       ...
     end   


How can I send a message to a user?

    #Send a message to beta
    Alerter::Message.notify_all(beta, "Short Message", "Long Message")
    
Or you can include an array of recipients

    recipients = [ alice, john, steve ]
    Alerter::Message.notify_all(recipients, "Short Message", "Long Message")    
    
How can I retrieve my conversations?
    
    #alfa wants to retrieve all his messages (read and unread)
    alfa.mailbox.inbox
    
    #alfa gets the last message (chronologically, the first in the inbox)
    message = alfa.mailbox.inbox.first
    
    # get only unread messages
    alfa.mailbox.inbox.unread
    
You can mark a message as read, unread or deleted or one or more users

    # for user alpha
    message.mark_as_read(alfa)
    message.mark_as_unread(alfa)
    message.mark_as_deleted(alfa)


You can change the way in which emails, SMS or mobile Push notifications are delivered by specifying a custom implementation of the mailer

    Alerter.setup do |config|
      config.email_message_mailer = CustomEmailMessageMailer
      config.sms_message_mailer   = CustomSmsMessageMailer
      config.push_message_mailer  = CustomPushMessageMailer
      ...
    end


## Contributing

1. Fork it ( https://github.com/[my-github-username]/alerter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
