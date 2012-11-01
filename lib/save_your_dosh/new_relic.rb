#
# A little proxy for the new-relic API
#
require 'json'
require 'nokogiri'

class SaveYourDosh::NewRelic

  THRESHOLD_CMD = %Q{
    curl https://api.newrelic.com/accounts/%{acc_id}/applications/%{app_id}/threshold_values.xml \
      -H "X-Api-Key: %{api_key}" 2> /dev/null
  }.strip

  #
  # Tries to check the application busyness in percents
  #
  # NOTE: returns `0` if the request have failed
  #
  def self.get_application_busyness
    conf = SaveYourDosh.config.new_relic

    data = THRESHOLD_CMD % {
      acc_id:  conf['acc_id'],
      app_id:  conf['app_id'],
      api_key: conf['api_key']
    }

    data = Nokogiri.parse(`#{data}`)

    data.css('threshold_value[name="Application Busy"]').each do |entry|
      return entry['metric_value'].to_f
    end

    nil # fallback
  end

  LOAD_CMD = %Q{
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

    data = LOAD_CMD % {
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
