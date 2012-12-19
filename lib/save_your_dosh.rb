#
# The namespace
#
module SaveYourDosh
  extend self

  VERSION = '0.0.0'

  autoload :Config,   'save_your_dosh/config.rb'
  autoload :Mangler,  'save_your_dosh/mangler.rb'
  autoload :NewRelic, 'save_your_dosh/new_relic.rb'


  def config
    @config ||= Config.new
  end

  def mangle!
    mangler ||= Mangler.new
    mangler.mangle_dynos!
    mangler.mangle_workers!
  end

  Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |ext|
    load ext
  } if defined?(Rake)

end
