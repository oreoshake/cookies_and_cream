# frozen_string_literal: true
# rails 3.1+
if defined?(Rails::Railtie)
  module CookiesAndCream
    class Railtie < Rails::Railtie
      isolate_namespace CookiesAndCream if defined? isolate_namespace # rails 3.0

      initializer "cookies_and_cream.middleware" do
        Rails.application.config.middleware.insert_before 0, CookiesAndCream::Middleware
      end
    end
  end
end
