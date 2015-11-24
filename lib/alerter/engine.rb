# Database foreign keys
require 'foreigner' if Rails.version < "4.2.0"
begin
  require 'sunspot_rails'
rescue LoadError
end

module Alerter
  class Engine < Rails::Engine
    isolate_namespace Alerter

    # config.generators do |g|
    #   g.test_framework :rspec
    #   g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    # end

    initializer "alerter.models.notifiable" do
      ActiveSupport.on_load(:active_record) do
        extend Alerter::Models::Notifiable::ActiveRecordExtension
      end
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end