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

  describe ".get_application_busyness" do
    it 'should make a request to the server for the data' do
      SaveYourDosh::NewRelic.should_receive(:`).

      with(%Q{
      curl https://api.newrelic.com/accounts/#{@config.new_relic['acc_id']}/applications/#{@config.new_relic['app_id']}/threshold_values.xml \
      -H "X-Api-Key: #{@config.new_relic['api_key']}" 2> /dev/null
      }.strip).

      and_return %Q{
        <?xml version="1.0" encoding="UTF-8"?>
        <threshold-values type="array">
          <threshold_value name="Apdex" metric_value="0.91" threshold_value="1" begin_time="2012-10-29 11:18:38" end_time="2012-10-29 11:21:38" formatted_metric_value="0.91 [0.5]*"/>
          <threshold_value name="Application Busy" metric_value="0.59" threshold_value="1" begin_time="2012-10-29 11:18:38" end_time="2012-10-29 11:21:38" formatted_metric_value="0.59%"/>
          <threshold_value name="Error Rate" metric_value="0.0" threshold_value="1" begin_time="2012-10-29 11:18:38" end_time="2012-10-29 11:21:38" formatted_metric_value="0%"/>
          <threshold_value name="Throughput" metric_value="3.7" threshold_value="1" begin_time="2012-10-29 11:18:38" end_time="2012-10-29 11:21:38" formatted_metric_value="3.7 rpm"/>
          <threshold_value name="Errors" metric_value="0.0" threshold_value="1" begin_time="2012-10-29 11:18:38" end_time="2012-10-29 11:21:38" formatted_metric_value="0 epm"/>
          <threshold_value name="Response Time" metric_value="391" threshold_value="1" begin_time="2012-10-29 11:18:38" end_time="2012-10-29 11:21:38" formatted_metric_value="391 ms"/>
          <threshold_value name="DB" metric_value="0.0" threshold_value="1" begin_time="2012-10-29 11:18:38" end_time="2012-10-29 11:21:38" formatted_metric_value="0%"/>
          <threshold_value name="CPU" metric_value="1.1" threshold_value="1" begin_time="2012-10-29 11:18:38" end_time="2012-10-29 11:21:38" formatted_metric_value="1.1%"/>
          <threshold_value name="Memory" metric_value="396" threshold_value="1" begin_time="2012-10-29 11:18:38" end_time="2012-10-29 11:21:38" formatted_metric_value="396 MB"/>
        </threshold-values>
      }

      SaveYourDosh::NewRelic.get_application_busyness.should == 0.59
    end

    it "should return nil in case if the server returned something wrong" do
      SaveYourDosh::NewRelic.should_receive(:`).
        and_return("Fuck you buddy")

      SaveYourDosh::NewRelic.get_application_busyness.should == nil
    end
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
