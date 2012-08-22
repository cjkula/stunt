require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'rack/utils'
require 'rack/test'
require 'rspec'
require 'capybara/rspec'
require 'capybara-webkit'
require 'stunt'

class StuntRackTestApp   
  def call(env)
    ''
  end 
end

include Capybara::DSL
Capybara.app = StuntRackTestApp.new
Capybara.default_driver = :webkit

class Stunt::Double 
  def itself
    _do_not_resolve_incr_
    self
  end
end