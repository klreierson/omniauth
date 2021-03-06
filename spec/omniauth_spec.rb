require 'helper'

describe OmniAuth do
  describe ".strategies" do
    it "increases when a new strategy is made" do
      expect{
        class ExampleStrategy
          include OmniAuth::Strategy
        end
      }.to change(OmniAuth.strategies, :size).by(1)
      expect(OmniAuth.strategies.last).to eq(ExampleStrategy)
    end
  end

  context "configuration" do
    describe ".defaults" do
      it "is a hash of default configuration" do
        expect(OmniAuth::Configuration.defaults).to be_kind_of(Hash)
      end
    end

    it "is callable from .configure" do
      OmniAuth.configure do |c|
        expect(c).to be_kind_of(OmniAuth::Configuration)
      end
    end

    before do
      @old_path_prefix = OmniAuth.config.path_prefix
      @old_on_failure  = OmniAuth.config.on_failure
    end

    after do
      OmniAuth.configure do |config|
        config.path_prefix = @old_path_prefix
        config.on_failure  = @old_on_failure
      end
    end

    it "is able to set the path" do
      OmniAuth.configure do |config|
        config.path_prefix = '/awesome'
      end

      expect(OmniAuth.config.path_prefix).to eq('/awesome')
    end

    it "is able to set the on_failure rack app" do
      OmniAuth.configure do |config|
        config.on_failure do
          'yoyo'
        end
      end

      expect(OmniAuth.config.on_failure.call).to eq('yoyo')
    end
    describe "mock auth" do
      before do
        OmniAuth.config.add_mock(:facebook, :uid => '12345',:info=>{:name=>'Joe', :email=>'joe@example.com'})
      end
      it "default should be AuthHash" do
        OmniAuth.configure do |config|
          expect(config.mock_auth[:default]).to be_kind_of(OmniAuth::AuthHash)
        end
      end
      it "facebook should be AuthHash" do
        OmniAuth.configure do |config|
          expect(config.mock_auth[:facebook]).to be_kind_of(OmniAuth::AuthHash)
        end
      end
      it "sets facebook attributes" do
        OmniAuth.configure do |config|
          expect(config.mock_auth[:facebook].uid).to eq('12345')
          expect(config.mock_auth[:facebook].info.name).to eq('Joe')
          expect(config.mock_auth[:facebook].info.email).to eq('joe@example.com')
        end
      end
    end
  end

  describe ".logger" do
    it "calls through to the configured logger" do
      OmniAuth.stub(:config => mock(:logger => "foo"))
      expect(OmniAuth.logger).to eq("foo")
    end
  end

  describe "::Utils" do
    describe ".deep_merge" do
      it "combines hashes" do
        expect(OmniAuth::Utils.deep_merge({'abc' => {'def' => 123}}, {'abc' => {'foo' => 'bar'}})).to eq({'abc' => {'def' => 123, 'foo' => 'bar'}})
      end
    end

    describe ".camelize" do
      it "works on normal cases" do
        {
          'some_word' => 'SomeWord',
          'AnotherWord' => 'AnotherWord',
          'one' => 'One',
          'three_words_now' => 'ThreeWordsNow'
        }.each_pair{ |k,v| expect(OmniAuth::Utils.camelize(k)).to eq(v) }
      end

      it "works in special cases that have been added" do
        OmniAuth.config.add_camelization('oauth', 'OAuth')
        expect(OmniAuth::Utils.camelize(:oauth)).to eq('OAuth')
      end
    end
  end
end
