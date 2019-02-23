# frozen_string_literal: true
# rails 3.1+
if defined?(Rails::Railtie)
  module SecureCookies
    class Railtie < Rails::Railtie
      isolate_namespace SecureCookies if defined? isolate_namespace # rails 3.0

      initializer "secure_cookies.middleware" do
        Rails.application.config.middleware.insert_before 0, SecureCookies::Middleware
      end
    end
  end
end
