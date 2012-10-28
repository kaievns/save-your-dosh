# Save Your Dosh

This is a little gem for [heroku](http://heroku.com) that automatically scales
both the workers and dynos in your heroku based app.

## Usage

Hook it up as a rubygem in your `Gemfile`

```ruby
gem 'save-your-dosh'
```

Add the configurations file `config/save-your-dosh.yaml`

```yml
new_relic:
  app_id:  myappid
  api_key: my api key

dynos:
  min: 1
  max: 5

workders:
  min:    1
  max:    5
  factor: 15  # jobs per worker

notify: me@boo-hoo.com, my-boss@boo-hoo.com
```

## Mailer Config

This gem will use the default mailer config of your rails app. So if you need
mailer configuration, change it inside of your application.


## Credits

The dynos scaling is implemented based on the work of [viki team](https://github.com/viki-org/heroku-autoscale)
and the workers scaling is implemented based on the [hirefire](https://github.com/meskyanichi/hirefire) project


## License

All the code in this package released under the terms of the MIT license
Copyright (C) 2012 Nikolay Nemshilov
