FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "User #{ n }" }
    sequence(:email) { |n| "user#{ n }@user.com" }
    factory :user_with_email_pref do
      after(:create) do |user|
        create_list(:email_prefs, 1, notifiable: user)
      end
    end
  end

  factory :cylon, class: User do
    sequence(:name) { |n| "Cylon #{ n }" }
    sequence(:email) { |n| "cylon#{ n }@cylon.com" }
  end

  factory :duck, class: User do
    sequence(:name) { |n| "Duck #{ n }" }
    sequence(:email) { |n| "duck#{ n }@duck.com" }
  end

  factory :email_prefs, class: Alerter::Preference do
    alert_methods %w(email)
    association :notification_type
  end

  factory :notification_type, class: Alerter::NotificationType do
    name 'info'
    initialize_with { Alerter::NotificationType.find_or_create_by(name: name)}
  end

  factory :message, class: Alerter::Message do
    short_msg 'short message'
    long_msg 'long message'
    association :notification_type
  end
end
