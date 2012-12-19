require 'rspec'
require 'heroku-api'

require File.dirname(__FILE__) + "/../lib/save_your_dosh.rb"

# mocking the Kernel::` calls in the new-relic API proxy
class SaveYourDosh::NewRelic
  def self.`(str)
    ''
  end
end

# disabling the Horoku::Client real interactions
class Heroku::API
  def initialize(*args)
  end

  def get_app(name)
    Struct.new(:body).new({'dynos' => 1, 'workers' => 1})
  end

  def put_dynos(name, qty)
  end

  def put_workers(name, qty)
  end
end
