require 'spec_helper'

describe Alerter::Mailbox do

  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)

    @receipt1 =  @entity1.send_message("short","long","normal")
    @receipt2 =  @entity2.send_message("short","long","normal")
    @receipt3 =  @entity1.send_message("short","long","normal")

    @msg1 = @receipt1.message
    @msg2 = @receipt2.message
    @msg3 = @receipt3.message
  end

  it "should return all mail" do
    expect(@entity1.mailbox.all_messages).to match_array([@msg1, @msg3])
    expect(@entity2.mailbox.all_messages).to match_array([@msg2])
  end


  it "should return inbox" do
    expect(@entity1.mailbox.inbox).to match_array([@msg1, @msg3])
  end

  it "should return trash" do
    expect(@entity1.mailbox.inbox).to match_array([@msg1])
    @receipt3 =  @entity1.send_message("short","long","normal")
    @msg3 = @receipt3.message
    expect(@entity1.mailbox.inbox).to match_array([@msg1, @msg3])
    @msg1.mark_as_deleted(@entity1)
    expect(@entity1.mailbox.trash).to match_array([@msg1])
  end

  it "should understand the read option" do
    expect(@entity1.mailbox.inbox.read).to match_array([])
    expect(@entity1.mailbox.inbox.unread).to match_array([@msg1, @msg3])
    @msg1.mark_as_read(@entity1)
    expect(@entity1.mailbox.inbox.read).to match_array([@msg1])
  end

  it "should understand the unread option" do
    expect(@entity1.mailbox.inbox.unread).to match_array([@msg1, @msg3])
    expect(@entity1.mailbox.inbox.read).to match_array([])
    @msg3.mark_as_read(@entity1)
    expect(@entity1.mailbox.inbox.read).to match_array([@msg3])
  end

  pending "should ensure deleted messages are not shown in inbox" do
    expect(@entity1.mailbox.inbox.unread).to match_array([@msg1, @msg3])
    @msg3.mark_as_deleted(@entity1)
    expect(@entity1.mailbox.inbox.unread).to match_array([@msg1])
    #expect(@entity1.mailbox.all_messages).to match_array([@msg1]) Should this pass?
  end




end
