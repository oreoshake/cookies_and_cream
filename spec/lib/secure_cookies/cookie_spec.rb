# frozen_string_literal: true
require "spec_helper"

module SecureCookies
  describe Cookie do
    let(:raw_cookie) { "_session=thisisatest" }

    it "does not tamper with cookies when using OPT_OUT is used" do
      cookie = Cookie.new(raw_cookie, OPT_OUT)
      expect(cookie.to_s).to eq(raw_cookie)
    end

    it "applies httponly, secure, and samesite by default" do
      cookie = Cookie.new(raw_cookie, nil)
      expect(cookie.to_s).to eq("_session=thisisatest; secure; HttpOnly; SameSite=Lax")
    end

    it "preserves existing attributes" do
      cookie = Cookie.new("_session=thisisatest; secure", secure: true, httponly: OPT_OUT, samesite: OPT_OUT)
      expect(cookie.to_s).to eq("_session=thisisatest; secure")
    end

    it "prevents duplicate flagging of attributes" do
      cookie = Cookie.new("_session=thisisatest; secure", secure: true, httponly: OPT_OUT)
      expect(cookie.to_s.scan(/secure/i).count).to eq(1)
    end

    context "Secure cookies" do
      context "when configured with a boolean" do
        it "flags cookies as Secure" do
          cookie = Cookie.new(raw_cookie, secure: true, httponly: OPT_OUT, samesite: OPT_OUT)
          expect(cookie.to_s).to eq("_session=thisisatest; secure")
        end
      end

      context "when configured with a Hash" do
        it "flags cookies as Secure when whitelisted" do
          cookie = Cookie.new(raw_cookie, secure: { only: ["_session"]}, httponly: OPT_OUT, samesite: OPT_OUT)
          expect(cookie.to_s).to eq("_session=thisisatest; secure")
        end

        it "does not flag cookies as Secure when excluded" do
          cookie = Cookie.new(raw_cookie, secure: { except: ["_session"] }, httponly: OPT_OUT, samesite: OPT_OUT)
          expect(cookie.to_s).to eq("_session=thisisatest")
        end
      end
    end

    context "HttpOnly cookies" do
      context "when configured with a boolean" do
        it "flags cookies as HttpOnly" do
          cookie = Cookie.new(raw_cookie, httponly: true, secure: OPT_OUT, samesite: OPT_OUT)
          expect(cookie.to_s).to eq("_session=thisisatest; HttpOnly")
        end
      end

      context "when configured with a Hash" do
        it "flags cookies as HttpOnly when whitelisted" do
          cookie = Cookie.new(raw_cookie, httponly: { only: ["_session"]}, secure: OPT_OUT, samesite: OPT_OUT)
          expect(cookie.to_s).to eq("_session=thisisatest; HttpOnly")
        end

        it "does not flag cookies as HttpOnly when excluded" do
          cookie = Cookie.new(raw_cookie, httponly: { except: ["_session"] }, secure: OPT_OUT, samesite: OPT_OUT)
          expect(cookie.to_s).to eq("_session=thisisatest")
        end
      end
    end

    context "SameSite cookies" do
      it "flags SameSite=Lax" do
        cookie = Cookie.new(raw_cookie, samesite: { lax: { only: ["_session"] } }, secure: OPT_OUT, httponly: OPT_OUT)
        expect(cookie.to_s).to eq("_session=thisisatest; SameSite=Lax")
      end

      it "flags SameSite=Lax when configured with a boolean" do
        cookie = Cookie.new(raw_cookie, samesite: { lax: true}, secure: OPT_OUT, httponly: OPT_OUT)
        expect(cookie.to_s).to eq("_session=thisisatest; SameSite=Lax")
      end

      it "does not flag cookies as SameSite=Lax when excluded" do
        cookie = Cookie.new(raw_cookie, samesite: { lax: { except: ["_session"] } }, secure: OPT_OUT, httponly: OPT_OUT)
        expect(cookie.to_s).to eq("_session=thisisatest")
      end

      it "flags SameSite=Strict" do
        cookie = Cookie.new(raw_cookie, samesite: { strict: { only: ["_session"] } }, secure: OPT_OUT, httponly: OPT_OUT)
        expect(cookie.to_s).to eq("_session=thisisatest; SameSite=Strict")
      end

      it "does not flag cookies as SameSite=Strict when excluded" do
        cookie = Cookie.new(raw_cookie, samesite: { strict: { except: ["_session"] }}, secure: OPT_OUT, httponly: OPT_OUT)
        expect(cookie.to_s).to eq("_session=thisisatest")
      end

      it "flags SameSite=Strict when configured with a boolean" do
        cookie = Cookie.new(raw_cookie, {samesite: { strict: true}, secure: OPT_OUT, httponly: OPT_OUT})
        expect(cookie.to_s).to eq("_session=thisisatest; SameSite=Strict")
      end

      it "flags properly when both lax and strict are configured" do
        raw_cookie = "_session=thisisatest"
        cookie = Cookie.new(raw_cookie, samesite: { strict: { only: ["_session"] }, lax: { only: ["_additional_session"] } }, secure: OPT_OUT, httponly: OPT_OUT)
        expect(cookie.to_s).to eq("_session=thisisatest; SameSite=Strict")
      end

      it "ignores configuration if the cookie is already flagged" do
        raw_cookie = "_session=thisisatest; SameSite=Strict"
        cookie = Cookie.new(raw_cookie, samesite: { lax: true }, secure: OPT_OUT, httponly: OPT_OUT)
        expect(cookie.to_s).to eq(raw_cookie)
      end

      it "samesite: true sets all cookies to samesite=lax" do
        raw_cookie = "_session=thisisatest"
        cookie = Cookie.new(raw_cookie, samesite: true, secure: OPT_OUT, httponly: OPT_OUT)
        expect(cookie.to_s).to eq("_session=thisisatest; SameSite=Lax")
      end
    end
  end
end
