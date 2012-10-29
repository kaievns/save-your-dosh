#
# The config object
#
require 'yaml'

class SaveYourDosh::Config
  DEFAULTS = File.dirname(__FILE__) + "/../save_your_dosh.yml"
  KEYS     = %w{ new_relic heroku dynos workers notify interval }

  KEYS.each{ |key| attr_accessor key }

  def initialize
    @new_relic = {
      'acc_id'  => ENV['NEW_RELIC_ID'],
      'app_id'  => ENV['NEW_RELIC_APP_ID'],
      'api_key' => ENV['NEW_RELIC_API_KEY']
    }

    @heroku = {
      'app_id'   => ENV['APP_NAME'],
      'login'    => ENV['SYD_LOGIN'],
      'password' => ENV['SYD_PASSWORD']
    }

    read DEFAULTS
  end

  def read(file)
    config = YAML.load_file(file)

    KEYS.each do |key|
      instance_variable_set "@#{key}", config[key] if config.has_key?(key)
    end

    @new_relic['app_id'] = SaveYourDosh::NewRelic.get_app_id(self)
  end

end

