require 'spec_helper'

describe SaveYourDosh::NewRelic do

  describe ".get_app_id" do
    before do
      @config = SaveYourDosh::Config.new
      @config.new_relic = {
        'acc_id'  => 'acc-id',
        'app_id'  => 'app-name',
        'api_key' => 'api-key'
      }
    end

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

end
