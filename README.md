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

Alerter uses a `Alerter::Message` object that requires a short_msg and long_msg to accommodate different delivery
platforms.  You can configure the maximum length of these in the initializer:

     Alerter.setup do |config|
       config.short_msg_length = 144 # Up to String length for your DB
       config.long_msg_length  = 512 # Any length you want
       ...
     end   


How can I send a message to a user?

    #Send a message to beta
    beta.send_message("Short Message", "Long Message", "Default")
    # Short Message, Long Message, Notification Type
    
Or you can include an array of recipients

    recipients = [ alice, john, steve ]
    Alerter::Message.message_all(recipients, "Short Message", "Long Message", "Default")
    
Whats a notification Type?

* The notification types are defined in the alerter initializer file.  Each message must be of one of these types.  When creating a message if the Notification Type is not yet in the DB, but is in this list it will be created int the DB.

```
    config.available_notification_types = ['General', 'System', 'Bad Entry']
```

How can I retrieve my conversations from inside my application?
    
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

How do I trigger a message to be delivered via Email, SMS, or mobile Push?

* The notifiable object (user) has a has_many relationship to alerter_preferences.  Each preference determine how a user wants to be alerted when a message that is tied to a specific notification type is generated.  A user can choose to be notified in multiple ways for the same message.
  
``` 
    notification_type = Alerter::NotificationType::find_or_create_by(name: 'Default')
    pref = user.alerter_preferences.find_or_create_by(notification_type: notification_type)
    pref.update_attribute(:alert_methods, ['email', 'push_notification'])
```

When using the default delivery systems your notifiable object must support a set of corresponding methods/settings.  Each of these functions can be changed in the config.  The defaults are listed in the initializer file.

* Email

```
  #config.email_method = :email # Returns the notifiable objects email address
  #config.name_method = :name # Returns the notifiable objects friendly name
```

* Push

```
  #config.push_data_method = :push_data # Returns an array of push information hashes of the form [{type: :ios, token: 'a7b...756'}]
  #config.ios_app_name = 'ios_app'
  #config.android_app_name = 'android_app'
  #config.android_priority = 'normal' #high
```

 * The push feature relies on the rpush gem.  You will need to reate the Rpush::App objects in your system.  Alerter will then look up the app info (by name) when sending.


You can change the way in which Emails, SMS, mobile Push notifications are delivered by specifying a custom method

    Alerter.setup do |config|
      config.custom_email_delivery_proc = :my_email_method
      config.custom_push_delivery_proc = :my_push_method
      config.custom_sms_delivery_proc = :my_sms_method
    end


## Contributing

1. Fork it ( https://github.com/[my-github-username]/alerter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
