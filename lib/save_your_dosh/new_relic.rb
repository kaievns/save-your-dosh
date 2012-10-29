#
# A little proxy for the new-relic API
#
require 'nokogiri'

class SaveYourDosh::NewRelic
  APPS_CMD = %Q{
    curl https://api.newrelic.com/accounts/%{acc_id}/applications.xml \
      -H "X-Api-Key: %{api_key}" 2> /dev/null
  }.strip

  def self.get_app_id(config)
    app_id = (config.new_relic['app_id'] || '').to_s

    if !(app_id =~ /^\d+$/)
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

end
