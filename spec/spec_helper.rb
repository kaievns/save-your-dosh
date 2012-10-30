
require 'rspec'
require 'heroku'

require File.dirname(__FILE__) + "/../lib/save_your_dosh.rb"

# mocking the Kernel::` calls in the new-relic API proxy
class SaveYourDosh::NewRelic
  def self.`(str)
    ''
  end
end

# disabling the Horoku::Client real interactions
class Heroku::Client
  def initialize(login, password)
  end

  def dynos(name)
    1
  end

  def workers(name)
    1
  end

  def set_dynos(name, qty)
  end

  def set_workers(name, qty)
  end
end
