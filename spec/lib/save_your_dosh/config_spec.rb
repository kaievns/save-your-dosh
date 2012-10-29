require 'spec_helper'

describe SaveYourDosh::Config do
  describe "defaults" do
    before do
      ENV['NEW_RELIC_ID']      = 'acc-id'
      ENV['NEW_RELIC_APP_ID']  = 'app-id'
      ENV['NEW_RELIC_API_KEY'] = 'api-key'


      @config = SaveYourDosh::Config.new
    end

    it "should have default dynos data" do
      @config.dynos.should == {
        "min" => 1, "max" => 5
      }
    end

    it "should have default workders data" do
      @config.workers.should == {
        "min" => 1, "max" => 5, "jobs" => 20
      }
    end

    it "should read the new_relic settings from the ENV hash" do
      @config.new_relic.should == {
        'acc_id'  => ENV['NEW_RELIC_ID'],
        'app_id'  => ENV['NEW_RELIC_APP_ID'],
        'api_key' => ENV['NEW_RELIC_API_KEY']
      }
    end
  end
end
