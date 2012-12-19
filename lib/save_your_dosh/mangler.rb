#
# Mangles with the actual heroku settings
#
require 'heroku-api'

class SaveYourDosh::Mangler

  def initialize
    @config = SaveYourDosh.config
    @heroku = Heroku::API.new(api_key: @config.heroku['api_key'])
  end

  def mangle_dynos!
    mangle! :dynos do |qty|
      load = SaveYourDosh::NewRelic.get_dynos_load
      qty  + (load > @config.dynos['threshold'] ? 1 : -1)
    end
  end

  def mangle_workers!
    mangle! :workers do |qty|
      qty
    end
  end

private

  # a little wrapper to avoid problems with setting/getting
  # a wrong thing
  def mangle!(what, &block)
    qty     = @heroku.get_app(@config.heroku['app_id']).body[what.to_s]
    new_qty = yield(qty)

    min_qty = @config.send(what)['min']
    max_qty = @config.send(what)['max']

    new_qty = min_qty if new_qty < min_qty
    new_qty = max_qty if new_qty > max_qty

    if new_qty != qty
      @heroku.send("put_#{what}", @config.heroku['app_id'], new_qty)
    end
  end

end
