require 'action_view/helpers/tag_helper'
require 'active_support/core_ext/string/access'
require 'i18n/exceptions'

module ActionView
  # = Action View Translation Helpers
  module Helpers
    module TranslationHelper
      include TagHelper

      def select_translate(key, options = {})
        if !Rails.env.test? && params[:debug_i18n] == 'true'
          key
        else
          translate(key, options)
        end
      rescue
        translate(key, options)
      end
      alias_method :t, :select_translate
    end
  end
end
