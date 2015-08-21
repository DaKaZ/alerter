
# Database foreign keys
require 'foreigner' if Rails.version < "4.2.0"
begin
  require 'sunspot_rails'
rescue LoadError
end

module Alerter
  class Engine < Rails::Engine
    initializer "alerter.models.notifiable" do
      ActiveSupport.on_load(:active_record) do
        extend Alerter::Models::Notifiable::ActiveRecordExtension
      end
    end
  end
end