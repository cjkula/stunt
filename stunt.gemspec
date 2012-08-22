#% cat stunt.gemspec
Gem::Specification.new do |s|
  
  s.name        = 'stunt'
  s.version     = '0.0.2.pre'
  s.date        = '2012-03-30'
  s.summary     = "Drive JavaScript development using existing Ruby specs."
  s.description = "Tool to map Ruby RSpec tests into a native Javascript application in order to be able to drive multiple (sequential or parallel) builds using an overlapping test suite."
  s.authors     = ["Christopher Kula"]
  s.email       = 'cjkula@gmail.com'
  s.files       = ["lib/stunt.rb"]
  s.homepage    = 'http://rubygems.org/gems/stunt'

  s.add_dependency("rspec", "> 2.0.0")
  s.add_dependency("capybara")

  s.add_development_dependency("bundler")
  s.add_development_dependency("rack")
  s.add_development_dependency("rack-test")
  s.add_development_dependency("capybara-webkit")
  
end
