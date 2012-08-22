require 'spec_helper'

# Tests the 'abstract' Stunt::Base.map!(class, class...) function
# Stunt::Base is intended to be subclassed in any particular implementation, but this method
# should not generally need to be overridden.
# 
# :map! takes over classes, saving a reference to the original class inside the new class
# which is used (later) to check on method existence when building the remote-language method chain.
#
# USAGE -
# Pass one or more classes as argument or in an array.

describe "Stunt::Base#map!" do
  before(:each) do
    Object.send(:remove_const, :TestClass) if Object.const_defined?(:TestClass)
    Object.const_set :TestClass, Class.new
    TestClass.const_set :SubClass, Class.new
    Object.send(:remove_const, :TestClass2) if Object.const_defined?(:TestClass2)
    Object.const_set :TestClass2, Class.new
    TestClass2.const_set :SubClass2, Class.new
    TestClass2::SubClass2.const_set :SubSubClass2, Class.new
  end
  it "should reassign the target class constant to point to a new subclass of Stunt::Double" do
    Stunt::Base.map!(TestClass)
    TestClass.ancestors.include?(Stunt::Double).should be_true
  end
  it "should map each class in an array of classes" do
    Stunt::Base.map!([TestClass,TestClass2])
    TestClass.ancestors.include?(Stunt::Double).should be_true
    TestClass2.ancestors.include?(Stunt::Double).should be_true
  end
  it "should map each class in an argument list" do
    Stunt::Base.map!(TestClass,TestClass2)
    TestClass.ancestors.include?(Stunt::Double).should be_true
    TestClass2.ancestors.include?(Stunt::Double).should be_true
  end
  it "should accept namespaced classes" do
    Stunt::Base.map!(TestClass::SubClass)
    TestClass::SubClass.ancestors.include?(Stunt::Double).should be_true
  end
  it "should accept nested namespaced classes" do
    Stunt::Base.map!(TestClass2::SubClass2::SubSubClass2)
    TestClass2::SubClass2::SubSubClass2.ancestors.include?(Stunt::Double).should be_true
  end
  it "should store a reference to the original class" do
    TestClass.send(:define_method, :hello) {'world'}    
    hold_class = TestClass
    Stunt::Base.map!(TestClass)
    TestClass._proxied_class_.should == hold_class
    TestClass._proxied_class_.new.hello.should == 'world'
    TestClass.instance_methods.include?(:hello).should be_false
    lambda {
      TestClass.new.hello
    }.should_not raise_error
  end
  it "should mark an original class as being proxied" do
    Stunt::Base.map!(TestClass)
    Stunt::Base.proxied_classes.include?(TestClass.to_s).should be_true
  end
  it "should mark an original namespaced class as being proxied" do
    Stunt::Base.map!(TestClass::SubClass)
    Stunt::Base.proxied_classes.include?(TestClass::SubClass.to_s).should be_true
  end
end