# frozen_string_literal: true
require "spec_helper"

module CookiesAndCream
  describe Middleware do
    let(:cookie_app) { lambda { |env| [200, env.merge("Set-Cookie" => "foo=bar"), "app"] } }
    let(:cookie_middleware) { Middleware.new(cookie_app) }

    after(:each) do
      if CookiesAndCream.instance_variable_defined?(:@config)
        CookiesAndCream.remove_instance_variable(:@config)
      end
    end

    context "cookies should be flagged" do
      it "flags cookies as secure" do
        CookiesAndCream.config = { secure: true, httponly: OPT_OUT, samesite: OPT_OUT }
        request = Rack::Request.new("HTTPS" => "on")
        _, env = cookie_middleware.call request.env
        expect(env["Set-Cookie"]).to eq("foo=bar; secure")
      end
    end

    it "allows opting out of cookie protection with OPT_OUT alone" do
      CookiesAndCream.config = OPT_OUT

      # do NOT make this request https. non-https requests modify a config,
      # causing an exception when operating on OPT_OUT. This ensures we don't
      # try to modify the config.
      request = Rack::Request.new({})
      _, env = cookie_middleware.call request.env
      expect(env["Set-Cookie"]).to eq("foo=bar")
    end

    context "cookies should not be flagged" do
      it "does not flags cookies as secure" do
        CookiesAndCream.config = { secure: OPT_OUT, httponly: OPT_OUT, samesite: OPT_OUT}
        request = Rack::Request.new("HTTPS" => "on")
        _, env = cookie_middleware.call request.env
        expect(env["Set-Cookie"]).to eq("foo=bar")
      end
    end

    it "flags cookies from configuration" do
      CookiesAndCream.config = { secure: true, httponly: true, samesite: { lax: true }}
      request = Rack::Request.new("HTTPS" => "on")
      _, env = cookie_middleware.call request.env

      expect(env["Set-Cookie"]).to eq("foo=bar; secure; HttpOnly; SameSite=Lax")
    end

    it "has a default configuration" do
      request = Rack::Request.new("HTTPS" => "on")
      _, env = cookie_middleware.call request.env

      expect(env["Set-Cookie"]).to eq("foo=bar; secure; HttpOnly; SameSite=Lax")
    end

    it "flags cookies with a combination of SameSite configurations" do
      cookie_middleware = Middleware.new(lambda { |env| [200, env.merge("Set-Cookie" => ["_session=foobar", "_guest=true"]), "app"] })

      CookiesAndCream.config = { samesite: { lax: { except: ["_session"] }, strict: { only: ["_session"] } }, httponly: OPT_OUT, secure: OPT_OUT }
      request = Rack::Request.new("HTTPS" => "on")
      _, env = cookie_middleware.call request.env

      expect(env["Set-Cookie"]).to match("_session=foobar; SameSite=Strict")
      expect(env["Set-Cookie"]).to match("_guest=true; SameSite=Lax")
    end

    it "disables cookies and cream for non-https requests" do
      CookiesAndCream.config = { secure: true, httponly: OPT_OUT, samesite: OPT_OUT }

      request = Rack::Request.new("HTTPS" => "off")
      _, env = cookie_middleware.call request.env
      expect(env["Set-Cookie"]).to eq("foo=bar")
    end

    it "sets the secure cookie flag correctly on interleaved http/https requests" do
      CookiesAndCream.config = { secure: true, httponly: OPT_OUT, samesite: OPT_OUT }

      request = Rack::Request.new("HTTPS" => "off")
      _, env = cookie_middleware.call request.env
      expect(env["Set-Cookie"]).to eq("foo=bar")
      $debug = true

      request = Rack::Request.new("HTTPS" => "on")
      _, env = cookie_middleware.call request.env
      expect(env["Set-Cookie"]).to eq("foo=bar; secure")
    end
  end
end
