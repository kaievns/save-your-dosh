require 'spec_helper'

describe SaveYourDosh::NewRelic do
  before do
    @config = SaveYourDosh.config
    @config.new_relic = {
      'acc_id'  => 'acc-id',
      'app_id'  => 'app-name',
      'api_key' => 'api-key'
    }
  end

  describe ".get_dynos_load" do
    it "should make a request to the server for the data" do
      SaveYourDosh::NewRelic.should_receive(:`).

      with(%Q{
      curl --silent -H "x-api-key: #{@config.new_relic['api_key']}" \
      -d "metrics[]=Instance/Busy" \
      -d "field=busy_percent" \
      -d "begin=#{Time.now - @config.interval * 60}" \
      -d "end=#{Time.now}" \
      -d "summary=1" \
      -d "app=#{@config.new_relic['app_id']}" \
      https://api.newrelic.com/api/v1/accounts/#{@config.new_relic['acc_id']}/metrics/data.json
      }.strip).

      and_return %Q{
        [{"name":"Instance/Busy","app":"doshmosh","agent_id":513715,"busy_percent":2.299166620165731}]
      }

      SaveYourDosh::NewRelic.get_dynos_load.should == 2.299166620165731
    end

    it "should return nil if the server returns not JSON" do
      SaveYourDosh::NewRelic.should_receive(:`).
        and_return("Fuck you buddy")

      SaveYourDosh::NewRelic.get_dynos_load.should == nil
    end

    it "should return nil if the server returns wrong JSON" do
      SaveYourDosh::NewRelic.should_receive(:`).
        and_return('{"fuck": "you buddy"}')

      SaveYourDosh::NewRelic.get_dynos_load.should == nil
    end
  end

end
