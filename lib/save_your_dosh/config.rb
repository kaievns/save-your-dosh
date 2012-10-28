#
# The config object
#
require 'yaml'

class SaveYourDosh::Config
  DEFAULTS = File.dirname(__FILE__) + "/../save_your_dosh.yml"
  KEYS     = %w{ new_relic dynos workers notify }

  KEYS.each{ |key| attr_accessor key }

  def initialize
    read DEFAULTS
  end

  def read(file)
    config = YAML.load_file(file)

    KEYS.each do |key|
      instance_variable_set "@#{key}", config[key] if config.has_key?(key)
    end
  end

end

