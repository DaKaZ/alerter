class Alerter::MessageBuilder < Alerter::BaseBuilder

  protected

  def klass
    Alerter::Message
  end

  def short_msg
    params[:short_msg] || ''
  end

  def long_msg
    params[:long_msg] || ''
  end
end