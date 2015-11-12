require 'spec_helper'

module DuoApi
  describe Response do
    subject { described_class.new(http_response) }

    let(:http_response) do
      double "HTTP Response",
        :body => body,
        :code => code,
        :content_type => content_type
    end
    let(:body) { JSON.generate({ :response => { :status_msg => "Awesome!" } }) }
    let(:code) { "200" }
    let(:content_type) { "application/json" }

    it "reads body" do
      expect(subject.body).to eq({ "response" => { "status_msg" => "Awesome!" } })
    end

    it "finds the message" do
      expect(subject.message).to eq("Awesome!")
    end

    it "has a code" do
      expect(subject.code).to eq("200")
    end

    it "can return raw body" do
      expect(subject.raw_body).to eq(body)
    end

    it "has a content type" do
      expect(subject.content_type).to eq('application/json')
    end

    it { should be_json }
    it { should be_success }
    it { should_not be_unauthorized }

    describe "unsuccessful" do
      let(:code) { "400" }
      let(:body) { JSON.generate({ :message => "NOT Awesome!" }) }

      it { should_not be_success }
      it "finds the message" do
        expect(subject.message).to eq("NOT Awesome!")
      end
    end

    describe "unauthorized" do
      let(:code) { "401" }

      it { should_not be_success }
      it { should be_unauthorized }
    end

    describe "non-json" do
      let(:body) { "jumbleddata" }
      let(:content_type) { "image/png" }

      it "gets raw body" do
        expect(subject.body).to eq(body)
      end

      it { should_not be_json }
    end
  end
end
