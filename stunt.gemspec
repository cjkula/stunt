#% cat stunt.gemspec
Gem::Specification.new do |s|
  s.name        = 'stunt'
  s.version     = '0.0.1.pre'
  s.date        = '2012-03-30'
  s.summary     = "Drive JavaScript development using existing Ruby specs."
  s.description = "Tool to maps Ruby RSpec tests into a native Javascript application in order to be able to drive multiple (sequential or parallel) builds using a heavily-overlapping test suite."
  s.authors     = ["Christopher Kula"]
  s.email       = 'cjkula@gmail.com'
  s.files       = ["lib/stunt.rb"]
  s.homepage    = 'http://rubygems.org/gems/stunt'
end