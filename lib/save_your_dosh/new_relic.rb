#
# A little proxy for the new-relic API
#
require 'nokogiri'

class SaveYourDosh::NewRelic
  APPS_CMD = %Q{
    curl https://api.newrelic.com/accounts/%{acc_id}/applications.xml \
      -H "X-Api-Key: %{api_key}" 2> /dev/null
  }.strip

  THRESHOLD_CMD = %Q{
    curl https://api.newrelic.com/accounts/%{acc_id}/applications/%{app_id}/threshold_values.xml \
      -H "X-Api-Key: %{api_key}" 2> /dev/null
  }.strip

  #
  # Tries to figure the actual app-id in case if the
  # user specified the app-name instead
  #
  def self.get_app_id(config)
    app_id = (config.new_relic['app_id'] || '').to_s

    if app_id.size > 0 && !(app_id =~ /^\d+$/)
      data = APPS_CMD % {
        acc_id:  config.new_relic['acc_id'],
        api_key: config.new_relic['api_key']
      }

      data = Nokogiri.parse(`#{data}`)

      data.css('application').each do |app|
        id   = app.css('id')[0]
        name = app.css('name')[0]

        if id && name
          return id.content if name.content == app_id
        end
      end

      return nil
    end

    app_id
  end

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

end

# cmd = %Q{
#   curl --silent -H "x-api-key: 2b898de6a0199a9738d51a691a047fabc83e0f8020bf49e" \
#   -d "metrics[]=Instance/Busy" \
#   -d "field=busy_percent" \
#   -d "begin=#{(Time.now - 3 * 60)}" \
#   -d "end=#{Time.now}" \
#   -d "summary=1" \
#   -d "app=doshmosh" \
#   https://api.newrelic.com/api/v1/accounts/81612/metrics/data.json
# }.strip

# # "metric_type" => "Instance/Busy",
# #  "fields" => "busy_percent",

# puts "\n--------\n"
# puts cmd
# puts "\n"
# puts `#{cmd}`
# puts "\n"
