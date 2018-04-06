require 'rails_helper'

RSpec.describe Cacheline, type: :model do
  context "validates input" do
    specify "validates URL" do
      expect {
        create :cacheline, url_minus_auth: "foo"
      }.to raise_error ActiveRecord::RecordInvalid, /Validation failed: Url minus auth is not a valid URI, Url minus auth is for an unknown API for which we may need to strip credentials/
    end

    specify "validates HTTP status" do
      expect {
        create :cacheline, http_status: 204
      }.to raise_error ActiveRecord::RecordInvalid, /Validation failed: Http status must be equal to 200/
    end
  end

  context "strips authentication" do
    let(:url_with_auth0) { "https://api.data.charitynavigator.org/v2/Organizations?app_id=CHARITYNAVIGATORAPPID&app_key=CHARITYNAVIGATORAPPKEY" }
    let(:url_without_auth0) { "https://api.data.charitynavigator.org/v2/Organizations?" }

    specify "for charitynavigator" do
      cl0 = create :cacheline, url_minus_auth: url_with_auth0
      expect(cl0.url_minus_auth).to eq url_without_auth0
      cl1 = build :cacheline, url_minus_auth: url_with_auth0
      expect(cl1.url_minus_auth).to eq url_with_auth0
      expect {
        cl1.save!
      }.to raise_error ActiveRecord::RecordNotUnique
      cl0.destroy
      cl1.save!
      expect(cl1.reload.url_minus_auth).to eq url_without_auth0
    end
  end

  context "compresses bodies" do
    let(:foo) { create :cacheline, uncompressed_body: "foo" }
    let(:foofoofoo) { create :cacheline, uncompressed_body: "foo"*100 }

    specify "foo" do
      expect(foo.uncompressed_body).to eq "foo"
      expect(foo.reload.uncompressed_body).to eq "foo"
      expect(foo.reload.body).to eq "eAFLy88HAAKCAUU="
    end

    specify "foofoo..." do
      expect(foofoofoo.uncompressed_body).to eq "foo"*100
      expect(foofoofoo.body.size).to eq 24
    end
  end

  context "#lookup_cacheline" do
    let(:url) { "https://api.data.charitynavigator.org/v2/Organizations" }
    let!(:line) { create :cacheline, url_minus_auth: url+"?x=1", uncompressed_body: "chandler37 was here" }

    specify "finds a cacheline" do
      cl = described_class.lookup_cacheline(url, {x: "1"})
      expect(cl).to eq(line)
      expect(cl.uncompressed_body).to eq "chandler37 was here"
    end

    specify "does not find a cacheline" do
      expect(described_class.lookup_cacheline(url, {})).to be nil
      expect(described_class.lookup_cacheline(url, {x: "2"})).to be nil
      expect(described_class.lookup_cacheline(url, {x: "1", y: "2"})).to be nil
    end
  end

  context "#populate_cache!" do
    let(:url) { "https://api.data.charitynavigator.org/v2/Organizations" }
    let!(:line) { create :cacheline, url_minus_auth: url+"?x=1", uncompressed_body: "chandler37 was here" }

    specify "updates an existing line" do
      described_class.populate_cache!(url, {x: "1"}, "foo")
      expect(described_class.all.size).to eq 1
      expect(described_class.first.uncompressed_body).to eq "foo"
    end

    specify "creates a new line" do
      described_class.populate_cache!(url, {}, "body")
      expect(described_class.lookup_cacheline(url, {}).uncompressed_body).to eq "body"
      expect(described_class.all.size).to eq 2
    end
  end
end
