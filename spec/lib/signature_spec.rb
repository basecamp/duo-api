require 'spec_helper'

IKEY = "DIXXXXXXXXXXXXXXXXXX"
WRONG_IKEY = "DIXXXXXXXXXXXXXXXXXY"
SKEY = "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"
AKEY = "useacustomerprovidedapplicationsecretkey"

USER = "testuser"

INVALID_RESPONSE = "AUTH|INVALID|SIG"
EXPIRED_RESPONSE = "AUTH|dGVzdHVzZXJ8RElYWFhYWFhYWFhYWFhYWFhYWFh8MTMwMDE1Nzg3NA==|cb8f4d60ec7c261394cd5ee5a17e46ca7440d702"
FUTURE_RESPONSE = "AUTH|dGVzdHVzZXJ8RElYWFhYWFhYWFhYWFhYWFhYWFh8MTYxNTcyNzI0Mw==|d20ad0d1e62d84b00a3e74ec201a5917e77b6aef"
WRONG_PARAMS_RESPONSE = "AUTH|dGVzdHVzZXJ8RElYWFhYWFhYWFhYWFhYWFhYWFh8MTYxNTcyNzI0M3xpbnZhbGlkZXh0cmFkYXRh|6cdbec0fbfa0d3f335c76b0786a4a18eac6cdca7"
WRONG_PARAMS_APP = "APP|dGVzdHVzZXJ8RElYWFhYWFhYWFhYWFhYWFhYWFh8MTYxNTcyNzI0M3xpbnZhbGlkZXh0cmFkYXRh|7c2065ea122d028b03ef0295a4b4c5521823b9b5"

module DuoApi
  describe Signature do
    before do
      DuoApi.config do |config|
        config.integration_key = IKEY
        config.secret_key = SKEY
        config.app_secret = AKEY
      end
    end

    describe "#sign" do
      describe "valid keys" do
        let(:signed_request) { DuoApi::Signature.sign(USER) }

        specify { expect(signed_request).to be_a(String) }
        specify { expect(signed_request).to_not be_empty }
      end

      describe "invalid keys" do
        describe "blank integration key" do
          before do
            DuoApi.config do |config|
              config.integration_key = ""
            end
          end

          it "throws error" do
            expect { DuoApi::Signature.sign(USER) }.to raise_error(InvalidConfiguration)
          end
        end

        describe "blank secret key" do
          before do
            DuoApi.config do |config|
              config.secret_key = nil
            end
          end

          it "throws error" do
            expect { DuoApi::Signature.sign(USER) }.to raise_error(InvalidConfiguration)
          end
        end

        describe "blank app secret" do
          before do
            DuoApi.config do |config|
              config.secret_key = ""
            end
          end

          it "throws error" do
            expect { DuoApi::Signature.sign(USER) }.to raise_error(InvalidConfiguration)
          end
        end
      end
    end

    describe "#verify" do
      describe "valid signature" do
        let(:request_sig) { DuoApi.sign(USER) }
        let(:app_sig) { request_sig.to_s.split(':')[1] }

        it "is nil with invalid user" do
          expect(Signature.verify("#{INVALID_RESPONSE}:#{app_sig}")).to be_nil
        end

        it "is nil when expired" do
          expect(Signature.verify("#{EXPIRED_RESPONSE}:#{app_sig}")).to be_nil
        end

        it "is valid with future response" do
          expect(Signature.verify("#{FUTURE_RESPONSE}:#{app_sig}")).to eq(USER)
        end

        it "is nil with wrong params" do
          expect(Signature.verify("#{WRONG_PARAMS_RESPONSE}:#{app_sig}")).to be_nil
        end
      end

      describe "invalid signature" do
        it "is nil with unmatching app signature" do
          request_sig = DuoApi.sign(USER)
          app_sig = request_sig.to_s.split(':')[1]

          DuoApi.config { |config| config.app_secret = "invalid" * 6 }

          expect(Signature.verify("#{FUTURE_RESPONSE}:#{app_sig}")).to be_nil
        end

        it "is nil with wrong params for app" do
          expect(Signature.verify("#{FUTURE_RESPONSE}:#{WRONG_PARAMS_APP}")).to be_nil
        end
      end
    end
  end
end
