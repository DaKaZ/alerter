class Alerter::MessageMailer < Alerter::BaseMailer
  #Sends and email with the message
  def send_email(message, receiver)
    @message  = message
    @receiver = receiver
    set_subject(message)
    mail :to => receiver.send(Alerter.email_method, message),
         :subject => t('alerter.message_mailer.subject_new', :subject => @subject),
         :template_name => 'new_message_email'
  end

end