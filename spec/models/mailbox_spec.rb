require 'spec_helper'

describe Alerter::Mailbox do

  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)

    @receipt1 =  @entity1.send_message("short","long","normal")
    @receipt2 =  @entity2.send_message("short","long","normal")

    @msg1 = @receipt1.message
    @msg2 = @receipt2.message
  end

  it "should return all mail" do
    expect(@entity1.mailbox.all_messages).to match_array([@msg1])
    expect(@entity2.mailbox.all_messages).to match_array([@msg2])
  end


  it "should return inbox" do
    expect(@entity1.mailbox.inbox).to match_array([@msg1])
  end

  it "should understand the read option" do
    expect(@entity1.mailbox.inbox(read: true)).to match_array([@msg1])
    # TODO create multiple messages and one as read, ensure only one is returned
  end


  pending "should ensure deleted messages are not shown in inbox" do
    fail
  end




end
