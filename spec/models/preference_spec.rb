require 'spec_helper'

describe Alerter::Preference do

  before do
    @user = FactoryGirl.create(:user)
    @notification_type = Alerter::NotificationType.create(name: 'Info');
  end

  it "should return methods as an array" do
    expect(@user.notification_methods(@notification_type).is_a?(Array)).to be_truthy
  end

  it "should allow methods to set to nil" do
    @user.configure_notification_methods(@notification_type, nil)
    expect(@user.notification_methods(@notification_type)).to match_array([])
  end

  it "should allow a single method to be set" do
    @user.configure_notification_methods(@notification_type, nil)
    method = Alerter::available_notification_methods.sample
    @user.configure_notification_methods(@notification_type, method)
    expect(@user.notification_methods(@notification_type)).to match_array([ method ])
  end

  it "should allow multiple methods to be set" do
    @user.configure_notification_methods(@notification_type, nil)
    methods = Alerter::available_notification_methods
    @user.configure_notification_methods(@notification_type, methods)
    expect(@user.notification_methods(@notification_type)).to match_array( methods )
  end



end
