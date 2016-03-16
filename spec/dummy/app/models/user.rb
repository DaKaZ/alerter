class User < ActiveRecord::Base
  acts_as_notifiable

  def push_data
    [type: :ios, token: 'a' * 64]
  end
end
