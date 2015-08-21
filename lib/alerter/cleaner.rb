require 'singleton'

module Alerter
  class Cleaner
    include Singleton
    include ActionView::Helpers::SanitizeHelper

  end
end