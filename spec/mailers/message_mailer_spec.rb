require 'spec_helper'

describe Alerter::MessageMailer do
  before do
    @entity1 = FactoryGirl.create :user_with_email_pref
    @entity2 = FactoryGirl.create :user_with_email_pref
    @entity3 = FactoryGirl.create :user
    @receipt1 = Alerter::Message.message_all([@entity1,@entity2,@entity3],"short", "long", "info")
  end
  
  it "should send emails when should_email? is true (2 out of 3)" do
    expect(ActionMailer::Base.deliveries.size).to eq 2
  end

  it "should send an email to user entity" do
    temp = false
    ActionMailer::Base.deliveries.each do |email|
      if email.to.first.to_s.eql? @entity1.email
      temp = true
      end
    end
    expect(temp).to be true
  end

  it "should send an email to second user entity" do
    temp = false
    ActionMailer::Base.deliveries.each do |email|
      if email.to.first.to_s.eql? @entity2.email
      temp = true
      end
    end
    expect(temp).to be true
  end

  it "shouldn't send an email to last entity due to prefs" do
    temp = false
    ActionMailer::Base.deliveries.each do |email|
      if email.to.first.to_s.eql? @entity3.email
      temp = true
      end
    end
    expect(temp).to be false
  end
end
