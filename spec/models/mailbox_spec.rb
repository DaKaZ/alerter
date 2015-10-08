require 'spec_helper'

describe Alerter::Mailbox do

  before do
    @entity1 = FactoryGirl.create(:user)
    @entity2 = FactoryGirl.create(:user)

  end

  it "should return all mail" do
    expect(@entity1.mailbox.inbox).to eq([])
  end

  pending "should return sentbox" do
    fail
  end

  pending "should return inbox" do
    fail
  end

  pending "should understand the read option" do
    fail
  end


  pending "should ensure deleted messages are not shown in inbox" do
    fail
  end




end
