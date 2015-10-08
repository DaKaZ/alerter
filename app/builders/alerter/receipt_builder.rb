class Alerter::ReceiptBuilder < Alerter::BaseBuilder

  protected

  def klass
    Alerter::Receipt
  end

  def mailbox_type
    params.fetch(:mailbox_type, 'inbox')
  end

end