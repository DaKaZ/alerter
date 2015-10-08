module Alerter
  module Models
    module Notifiable
      extend ActiveSupport::Concern

      module ActiveRecordExtension
        #Converts the model into messageable allowing it to interchange messages and
        #receive notifications
        def acts_as_notifiable
          include Notifiable
        end
      end


      included do
        has_many :messages, :class_name => "Alerter::Message", :as => :sender
        has_many :preferences, dependent: :destroy
        if Rails::VERSION::MAJOR == 4
          has_many :receipts, -> { order 'created_at DESC' }, :class_name => "Alerter::Receipt", dependent: :destroy, as: :receiver
        else
          # Rails 3 does it this way
          has_many :receipts, :order => 'created_at DESC',    :class_name => "Alerter::Receipt", :dependent => :destroy, :as => :receiver
        end
      end

      unless defined?(Alerter.name_method)
        # Returning any kind of identification you want for the model
        define_method Alerter.name_method do
          begin
            super
          rescue NameError
            return "You should add method :#{Alerter.name_method} in your Notifiable model"
          end
        end
      end

      unless defined?(Alerter.email_method)
        #Returning the email address of the model if an email should be sent for this Message.
        #If no mail has to be sent, return nil.
        define_method Alerter.email_method do |object|
          begin
            super
          rescue NameError
            return "You should add method :#{Alerter.email_method} in your Notifiable model"
          end
        end
      end

      #Gets the mailbox of the notifiable
      def mailbox
        @mailbox ||= Alerter::Mailbox.new(self)
      end

      # Get number of unread messages
      def unread_inbox_count
        mailbox.inbox(unread: true).count
      end


      #Sends a notification
      #as originator
      def send_message(short_msg, long_msg, obj = nil, sanitize_text = true, notification_code=nil)
        message = Alerter::MessageBuilder.new({
                                                    :recipients        => self,
                                                    :short_msg         => short_msg,
                                                    :long_msg          => long_msg,
                                                    :notified_object   => obj,
                                                    :notification_code => notification_code,
                                                }).build

        message.deliver sanitize_text
      end



      #Mark the object as read for notifiable.
      #Object can be:
      #* A Receipt
      #* A Message
      #* An Array of these
      #Optionally pass in details of the read receipt as String
      def mark_as_read(obj, details = nil)
        case obj
          when Alerter::Receipt
            obj.mark_as_read if obj.receiver == self
          when Alerter::Message
            obj.mark_as_read(self, details)
          when Array
            obj.map{ |sub_obj| mark_as_read(sub_obj, details) }
        end

      end

      #Mark the object as unread for notifiable.
      #
      #Object can be:
      #* A Receipt
      #* A Message
      #* An Array of these
      #Optionally pass in details of the un-read receipt as String
      def mark_as_unread(obj, details = nil)
        case obj
          when Alerter::Receipt
            obj.mark_as_unread if obj.receiver == self
          when Alerter::Message
            obj.mark_as_unread(self, details)
          when Array
            obj.map{ |sub_obj| mark_as_unread(sub_obj, details) }
        end
      end

      #Mark the object as deleted for notifiable.
      #
      #Object can be:
      #* A Receipt
      #* A Message
      #* An Array of these
      #Optionally pass in details of the deletion as String
      def mark_as_deleted(obj, details = nil)
        case obj
          when Receipt
            return obj.mark_as_deleted if obj.receiver == self
          when Message
            obj.mark_as_deleted(self, details)
          when Array
            obj.map{ |sub_obj| mark_as_deleted(sub_obj, details) }
          else
            return nil
        end
      end

    end
  end
end