
require 'rspec'

require File.dirname(__FILE__) + "/../lib/save_your_dosh.rb"

# mocking the Kernel::` calls in the new-relic API proxy
class SaveYourDosh::NewRelic
  def self.`(str)
    ''
  end
end
