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
    expect(@receipt1.deleted).to be_falsey
    @message1.mark_as_deleted(@entity1)
    expect(@message1.is_deleted?(@entity1)).to be_truthy
  end

  it "should be able to be marked as read" do
    expect(@message1.is_unread?(@entity1)).to be_truthy
    @message1.mark_as_read(@entity1)
    expect(@message1.is_read?(@entity1)).to be_truthy
  end

  it "should not be expired" do
    expect(@message1.expired?).to be_falsey
  end

  it "should include message in unexpired list" do
    expect(Alerter::Message.unexpired).to include @message1
  end

  it "should expire message" do
    @message1.expire!
    expect(@message1.expired?).to be_truthy
  end

  it "should include message in expired list" do
    @message1.expire!
    expect(Alerter::Message.expired).to include @message1
  end

  it "should not be global" do
    expect(Alerter::Message.global).to eq []
  end
end
