class Alerter::ViewsGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../../app/views/alerter", __FILE__)

  desc "Copy Alerter views into your app"
  def copy_views
    directory('message_mailer', 'app/views/alerter/message_mailer')
  end
end