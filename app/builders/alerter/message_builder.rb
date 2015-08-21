class Alerter::MessageBuilder < Alerter::BaseBuilder

  protected

  def klass
    Alerter::Message
  end

  def msg
    params[:msg] || "empty message"
  end

end