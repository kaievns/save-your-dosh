require 'spec_helper'

describe SaveYourDosh::Mangler do
  before do
    @config  = SaveYourDosh.config
    @config.heroku = {
      'app_id'   => 'my-app',
      'login'    => 'login',
      'password' => 'my-password'
    }

    @heroku  = Heroku::API.new(api_key: 'boo hoo')

    Heroku::API.should_receive(:new).
      with(api_key: @config.heroku['api_key']).
      and_return(@heroku)

    @mangler = SaveYourDosh::Mangler.new
  end

  describe ".mangle_dynos!" do
    before do
      @heroku.should_receive(:get_app).
        with(@config.heroku['app_id']).
        and_return(Struct.new(:body).new({'dynos' => 2, 'workers' => 1}))

      SaveYourDosh::NewRelic.should_receive(:get_dynos_load).
        and_return(40)
    end

    it "should try to add dynos if we're getting over the threshold" do
      @config.dynos['threshold'] = 30

      @heroku.should_receive(:put_dynos).
        with(@config.heroku['app_id'], 3)

      @mangler.mangle_dynos!
    end

    it "should try to remove dynos if we're below the threshold" do
      @config.dynos['threshold'] = 50

      @heroku.should_receive(:put_dynos).
        with(@config.heroku['app_id'], 1)

      @mangler.mangle_dynos!
    end

    it "should not go below minimal dynos amount" do
      @config.dynos['threshold'] = 50
      @config.dynos['min']       = 2
      @config.dynos['max']       = 2

      @heroku.should_not_receive(:put_dynos)

      @mangler.mangle_dynos!
    end

    it "should not go above dynos amount" do
      @config.dynos['threshold'] = 30
      @config.dynos['min']       = 1
      @config.dynos['max']       = 2

      @heroku.should_not_receive(:put_dynos)

      @mangler.mangle_dynos!
    end

  end
end
