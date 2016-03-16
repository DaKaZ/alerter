class User < ActiveRecord::Base
  acts_as_notifiable

  def ios_token
    'a' * 64
  end

  def android_token
    'b' * 64
  end
end
