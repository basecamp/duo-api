require 'spec_helper'
module DuoApi
  describe HeaderSignature do
    let(:client) do
      Client.new(:integration_key => "abc", :secret_key => "xyz", :hostname => "non-existent.example.com")
    end
    subject do
      described_class.new(client, "GET", "/a/path", nil)
    end

    it "builds basic auth" do
      username, password = subject.basic_auth

      expect(username).to eq(DuoApi.config.integration_key)
      expect(password).to be_a(String)
    end

    it "matches a date header" do
      expect(Time.rfc2822(subject.date_header)).to be_a(Time)
    end
  end
end
