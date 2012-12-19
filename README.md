# Save Your Dosh

This is a little gem for [heroku](http://heroku.com) that automatically scales
dynos in your heroku based app.

## Prerequisites

You obviously have to be on `heroku` and `rails`. You also need the New Relic RPM add-on
switched on. It doesn't matter whether you have a free or a pro account on new relic.

## Installation

Hook it up as a rubygem in your `Gemfile`

```ruby
gem 'save-your-dosh'
```

Make sure you have the following `ENV` vars in your heroku config

```
» heroku config
=== doshmosh Config Vars
.....
HEROKU_API_KEY:             your-heroku-api-key
NEW_RELIC_API_KEY:          your-new-relic-api-key
NEW_RELIC_APP_NAME:         your-app-name-on-new-relic
NEW_RELIC_ID:               your-account-id-on-new-relic
......
```

Once you've done with those, add the `rake save:your:dosh` task in heroku's scheduler
and set the minimal timeout of `10 mins`. (don't make it less than 6 mins, otherwise
new relic will kick your ass)

## Configuration

You can mangle with the settings by creating a file like that in your rails app `config/save-your-dosh.yaml`

```yml
dynos:
  min: 1
  max: 5
  threshold: 50 # % of system busyness when we kick in/out a dyno
```


## How It Works

It's pretty simple, every time you kick the `rake save:your:dosh` task via cron or scheduler,
it will make a request to the new relic servers for the data on your application business. If
it goes over the threshold, it will increase the amount of dynos until reaches the max number
from the config. Otherwise it will try to switch dynos off until reaches the minimal amount.


## License

All the code in this package released under the terms of the MIT license
Copyright (C) 2012 Nikolay Nemshilov
