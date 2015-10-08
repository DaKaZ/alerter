class Alerter::MessageBuilder < Alerter::BaseBuilder

  protected

  def klass
    Alerter::Message
  end

  def message
    params[:message] || "empty message"
  end
end