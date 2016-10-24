require 'rpush'
module Alerter
  class MethodNotImplemented < StandardError
    def initialize(data)
      @data = data
    end
  end

  class MessageDispatcher

    attr_reader :message, :recipients

    def initialize(message, recipients)
      @message, @recipients = message, recipients
    end

    def call
      return false unless (Alerter.notification_method - Alerter.available_notification_methods).empty? # array subtraction to see if notification methods are in the available list
      Alerter.notification_method.each do |method|
        case method
          when 'email'
            if Alerter.mailer_wants_array
              send_email(filtered_recipients(method))
            else
              filtered_recipients(method).each do |recipient|
                send_email(recipient) if recipient.send(Alerter.email_method).present?
                # filtered_re.. should enforce the not_method logic?
                #send_email(recipient) if recipient.notification_methods(message.notification_type).include?(method) && recipient.email.present?
              end
            end
          when 'push_notification'
            filtered_recipients(method).each do |recipient|
              send_push_alert(recipient)
            end
          when 'sms', 'twitter'
            # TODO: get these other types working
          when 'in_app'
            # Handled externally to alerter
          else
            raise MethodNotImplemented.new(method)
        end
      end
    end

    private

    def mailer
      klass = message.class.name.demodulize
      method = "#{klass.downcase}_mailer".to_sym
      Alerter.methods.include?(method) ? Alerter.send(method) : "#{message.class}Mailer".constantize
    end

    # recipients can be filtered on a notification type basis
    def filtered_recipients(method)
      recipients.each_with_object([]) do |recipient, array|
        pref = recipient.alerter_preferences.find_by(notification_type: message.notification_type)
        array << recipient if pref && recipient.notification_methods(message.notification_type).include?(method)
      end
    end


    def send_email(recipient)
      if Alerter.custom_email_delivery_proc
        Alerter.custom_email_delivery_proc.call(mailer, message, recipient)
      else
        email = mailer.send_email(message, recipient)
        email.respond_to?(:deliver_now) ? email.deliver_now : email.deliver
      end
    end

    def send_push_alert(recipient)
      if Alerter.custom_push_delivery_proc
        Alerter.custom_push_delivery_proc.call(message, recipient)
      else
        push_data = recipient.send(Alerter.push_data_method)
        if push_data.is_a?(Array)
          results = []
          push_data.each do |pd|
            case pd[:type]
              when :ios
                results << send_ios_alert(pd[:token])
              when :android
                results << send_android_alert(pd[:token])
              when :kindle
                results << send_kindle_alert(pd[:token])
              else
                results << false
            end
          end
          return results
        end
        false
      end
    end

    def send_ios_alert(token)
      unless token.nil?
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by(name: Alerter.ios_app_name)
        n.device_token = token
        n.alert = message.short_msg
        n.data = {data: message.push_data}
        n.save
      end
    end

    def send_android_alert(token)
      unless token.nil?
        n = Rpush::Gcm::Notification.new
        n.app = Rpush::Gcm::App.find_by(name: Alerter.android_app_name)
        n.registration_ids = [token]
        n.data = {message: message.short_msg, data: message.push_data}
        n.priority = (Alerter.android_priority)
        n.save
      end
    end

    def send_kindle_alert(token)
      unless token.nil?
        n = Rpush::Adm::Notification.new
        n.app = Rpush::Adm::App.find_by(name: Alerter.kindle_app_name)
        n.registration_ids = [token]
        n.data = {message: message.short_msg, data: message.push_data}
        n.save
      end
    end
  end
end