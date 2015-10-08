require 'spec_helper'

describe Alerter::Mailbox do

  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)

  end

  it "should return all mail" do
    expect(@entity1.mailbox.all_messages).to eq([])
  end


  it "should return inbox" do
    expect(@entity1.mailbox.inbox).to eq([])
  end

  it "should understand the read option" do
    expect(@entity1.mailbox.inbox(read: true)).to eq([])
    # TODO create multiple messages and one as read, ensure only one is returned
  end


  pending "should ensure deleted messages are not shown in inbox" do
    fail
  end




end
