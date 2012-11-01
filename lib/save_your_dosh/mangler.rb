#
# Mangles with the actual heroku settings
#
require 'heroku'

class SaveYourDosh::Mangler

  def initialize
    @config = SaveYourDosh.config
    @heroku = Heroku::Client.new(@config.heroku['login'], @config.heroku['password'])
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
    qty     = @heroku.send(what, @config.heroku['app_id'])
    new_qty = yield(qty)

    min_qty = @config.send(what)['min']
    max_qty = @config.send(what)['max']

    new_qty = min_qty if new_qty < min_qty
    new_qty = max_qty if new_qty > max_qty

    if new_qty != qty
      @heroku.send("set_#{what}", @config.heroku['app_id'], new_qty)
    end
  end

end
