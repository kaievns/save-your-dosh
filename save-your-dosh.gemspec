Gem::Specification.new do |s|
  s.name    = 'save-your-dosh'
  s.version = '1.0.3'
  s.date    = '2013-01-17'

  s.summary = "Heroku dynos auto-scaling thing"
  s.description = "This gem can automatically scale the dynos amount on your heroku app depending on your system busyness"

  s.authors  = ['Nikolay Nemshilov']
  s.email    = 'nemshilov@gmail.com'
  s.homepage = 'http://github.com/MadRabbit/save-your-dosh'
  s.add_dependency('heroku-api', '>= 0.3.7')
  s.add_dependency('json', '>= 1.7.5')

  s.files = Dir['lib/**/*'] + Dir['spec/**/*']
  s.files+= %w(
    README.md
    init.rb
    Gemfile
    Gemfile.lock
  )
end
