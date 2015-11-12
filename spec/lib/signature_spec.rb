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
    let(:integration_key) { IKEY }
    let(:secret_key) { SKEY }
    let(:app_secret) { AKEY }
    let(:client) do
      Client.new :integration_key => integration_key,
        :secret_key => secret_key,
        :app_secret => app_secret
    end
    subject { described_class.new(client) }

    describe "#sign" do
      describe "valid keys" do
        let(:signed_request) { subject.sign(USER) }

        specify { expect(signed_request).to be_a(String) }
        specify { expect(signed_request).to_not be_empty }
      end

      describe "invalid keys" do
        describe "blank integration key" do
          let(:integration_key) { "" }

          it "throws error" do
            expect { subject.sign(USER) }.to raise_error(InvalidConfiguration)
          end
        end

        describe "blank secret key" do
          let(:secret_key) { nil }

          it "throws error" do
            expect { subject.sign(USER) }.to raise_error(InvalidConfiguration)
          end
        end

        describe "blank app secret" do
          let(:secret_key) { "" }

          it "throws error" do
            expect { subject.sign(USER) }.to raise_error(InvalidConfiguration)
          end
        end
      end
    end

    describe "#verify" do
      describe "valid signature" do
        let(:request_sig) { subject.sign(USER) }
        let(:app_sig) { request_sig.to_s.split(':')[1] }

        it "is nil with invalid user" do
          expect(subject.verify("#{INVALID_RESPONSE}:#{app_sig}")).to be_nil
        end

        it "is nil when expired" do
          expect(subject.verify("#{EXPIRED_RESPONSE}:#{app_sig}")).to be_nil
        end

        it "is valid with future response" do
          expect(subject.verify("#{FUTURE_RESPONSE}:#{app_sig}")).to eq(USER)
        end

        it "is nil with wrong params" do
          expect(subject.verify("#{WRONG_PARAMS_RESPONSE}:#{app_sig}")).to be_nil
        end
      end

      describe "invalid signature" do
        it "is nil with unmatching app signature" do
          request_sig = subject.sign(USER)
          app_sig = request_sig.to_s.split(':')[1]

          new_client = client.tap { |client| client.app_secret = "invalid" * 6 }
          new_signer = described_class.new(client)

          expect(new_signer.verify("#{FUTURE_RESPONSE}:#{app_sig}")).to be_nil
        end

        it "is nil with wrong params for app" do
          expect(subject.verify("#{FUTURE_RESPONSE}:#{WRONG_PARAMS_APP}")).to be_nil
        end
      end
    end
  end
end
