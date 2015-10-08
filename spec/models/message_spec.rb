require 'spec_helper'

describe Alerter::Message do

  before do
    @entity1 = FactoryGirl.create(:user)
    message_disp = double('MessageDispatcher')
    expect(Alerter::MessageDispatcher).to receive(:new).with(instance_of(Alerter::Message), [@entity1]).and_return message_disp
    expect(message_disp).to receive(:call)
    @receipt1 = @entity1.send_message("Short","Long","MyType")
    @message1 = @receipt1.message
  end

  it "should have right recipients" do
  	expect(@receipt1.message.recipients.count).to eq 1
  end

  it "should be able to be marked as deleted" do
    expect(@receipt1.deleted).to be false
    @message1.mark_as_deleted (@entity1)
    expect(@message1.is_deleted?(@entity1)).to be true
  end

end
