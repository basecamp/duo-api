require 'spec_helper'

describe DuoApi do
  it 'has a version number' do
    expect(DuoApi::VERSION).not_to be nil
  end

  it "configs" do
    DuoApi.config do |config|
      config.app_secret = "abc"
    end

    expect(DuoApi.config.app_secret).to eq("abc")
  end

  it "sends GET to Request" do
    expect(DuoApi::Request).to receive(:request) { true }

    DuoApi.get("/auth/v2/check")
  end

  it "sends post to Request" do
    expect(DuoApi::Request).to receive(:request)

    DuoApi.post("/auth/v2/check")
  end

  it "signs" do
    expect(DuoApi::Signature).to receive(:sign).and_call_original

    expect(DuoApi.sign("jphenow")).to be_a String
  end

  it "verifies with Signature" do
    expect(DuoApi::Signature).to receive(:verify).and_call_original

    expect(DuoApi.verify("jumbled-reponse")).to be_nil
  end
end
