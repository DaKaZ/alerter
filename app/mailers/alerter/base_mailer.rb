class Alerter::BaseMailer < ActionMailer::Base
  default :from => Alerter.default_from

  private

  def set_subject()
    @subject  = Alerter.default_subject
  end

  def strip_tags(text)
    ::Alerter::Cleaner.instance.strip_tags(text)
  end

end