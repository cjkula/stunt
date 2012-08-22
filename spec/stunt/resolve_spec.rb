require 'spec_helper'

class TestClass
  extend Stunt::Helpers
  def some_method; end
end

Stunt::Base.map! TestClass

describe "Stunt#resolve" do
  context "JavaScript" do
    it "should send a proxy to be evaluated by the JavaScript driver"
  end
end