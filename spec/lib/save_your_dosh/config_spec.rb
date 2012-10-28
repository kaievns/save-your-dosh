require 'spec_helper'

describe SaveYourDosh::Config do
  describe "defaults" do
    before do
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
  end
end
