#
# A little proxy for the new-relic API
#
require 'json'

class SaveYourDosh::NewRelic

  DYNOS_LOAD_CMD = %Q{
    curl --silent -H "x-api-key: %{api_key}" \
      -d "metrics[]=Instance/Busy" \
      -d "field=busy_percent" \
      -d "begin=%{begin_time}" \
      -d "end=%{end_time}" \
      -d "summary=1" \
      -d "app=%{app_id}" \
      https://api.newrelic.com/api/v1/accounts/%{acc_id}/metrics/data.json
  }.strip

  def self.get_dynos_load
    conf = SaveYourDosh.config

    data = DYNOS_LOAD_CMD % {
      app_id:     conf.new_relic['app_id'],
      acc_id:     conf.new_relic['acc_id'],
      api_key:    conf.new_relic['api_key'],
      begin_time: Time.now - conf.interval * 60,
      end_time:   Time.now
    }

    JSON.parse(`#{data}`)[0]["busy_percent"]

  rescue JSON::ParserError, NoMethodError
    return nil
  end

end
