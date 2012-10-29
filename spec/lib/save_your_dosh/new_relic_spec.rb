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

  describe ".get_app_id" do

    it "should return the app-id as it is if it's numeric" do
      @config.new_relic['app_id'] = '12345'

      SaveYourDosh::NewRelic.get_app_id(@config).should == '12345'
    end

    it "should make a request to the server for the app-id if it's an app name" do
      SaveYourDosh::NewRelic.should_receive(:`).

      with(%Q{
      curl https://api.newrelic.com/accounts/#{@config.new_relic['acc_id']}/applications.xml \
      -H "X-Api-Key: #{@config.new_relic['api_key']}" 2> /dev/null
      }.strip).

      and_return %Q{
        <?xml version="1.0" encoding="UTF-8"?>
        <applications type="array">
          <application>
            <id type="integer">54321</id>
            <name>app-name</name>
            <overview-url>https://rpm.newrelic.com/accounts/acc-id/applications/54321</overview-url>
          </application>
        </applications>
      }.strip

      SaveYourDosh::NewRelic.get_app_id(@config).should == '54321'
    end

    it "should return nil if the server request returns invalid XML" do
      SaveYourDosh::NewRelic.should_receive(:`).
        and_return("Fuck you buddy")

      SaveYourDosh::NewRelic.get_app_id(@config).should == nil
    end

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

end
