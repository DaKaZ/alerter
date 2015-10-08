module Alerter
  class MethodNotImplemented < StandardError
    def initialize(data)
      @data = data
    end
  end

  class MessageDispatcher

    attr_reader :message, :recipients

    def initialize(message, recipients)
      @mailable, @recipients = message, recipients
    end

    def call
      return false unless (Alerter.notification_method - Alerter.available_notification_methods).empty? # array subtraction to see if notification methods are in the available list
      Alerter.notification_method.each do |method|
        case method
          when 'email'

            # binding.pry
            if Alerter.mailer_wants_array
              send_email(filtered_recipients(method))
            else
              filtered_recipients(method).each do |recipient|
                send_email(recipient) if recipient.preferences.methods.include?(method)
              end
            end
          when 'none', 'ios_push', 'android_push', 'sms', 'twitter'

          else
            raise MethodNotImplemented.new(method)
        end
      end
    end

    private

    def mailer
      klass = mailable.class.name.demodulize
      method = "#{klass.downcase}_mailer".to_sym
      Alerter.send(method) || "#{mailable.class}Mailer".constantize
    end

    # recipients can be filtered on a notification type basis
    def filtered_recipients(method)
      recipients.each_with_object([]) do |recipient, array|
        array << recipient if recipient.preferences.methods.include?(method)
      end
    end


    def send_email(recipient)
      if Alerter.custom_email_delivery_proc
        Alerter.custom_email_delivery_proc.call(mailer, mailable, recipient)
      else
        email = mailer.send_email(message, recipient)
        email.respond_to?(:deliver_now) ? email.deliver_now : email.deliver
      end
    end
  end
end