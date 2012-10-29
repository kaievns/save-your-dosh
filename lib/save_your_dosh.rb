#
# The namespace
#
module SaveYourDosh
  extend self

  VERSION = '0.0.0'

  autoload :Config,    'save_your_dosh/config.rb'
  autoload :NewRelic,  'save_your_dosh/new_relic.rb'
  autoload :Estimator, 'save_your_dosh/estimator.rb'

  def config
    @config ||= Config.new
  end

  def update!
    estimator = Estimator.new

  end

end
