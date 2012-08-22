require 'spec_helper'

## setup sample class definitions ##
class ParentClass
  def parent_method
    'parent method'
  end
  def self.class_parent_method
    'class parent method'
  end
end

class TestClass < ParentClass
  extend Stunt::Helpers
  def some_method; end
  def get_another; end
  method_return_class :get_another => 'AnotherClass'
  def self.some_class_method; end
end

class ChildClass < TestClass
  def child_method; end
end

class TestClassWithArgument
  extend Stunt::Helpers
  def initialize(args); end
end

class InvokingObjectClass
  extend Stunt::Helpers
  def get_test_object; end
  def self.class_get_test_object; end
  method_return_class :get_test_object => 'TestClass'
  class_method_return_class :class_get_test_object => 'TestClass'
end

class AnotherClass
  extend Stunt::Helpers
  def self.some_class_method; end
end

class JSTestClass
  extend Stunt::Helpers
  def js_method
  end
  def self.js_class_method
  end
end

## do the Stunt conversions ##
Stunt::Base.map! TestClass, ChildClass, TestClassWithArgument, InvokingObjectClass, AnotherClass
Stunt::JavaScript.map! JSTestClass

describe "Stunt::Double" do
    
  describe "the proxied class" do
    it "should be a descendent of Stunt::Double" do
      TestClass.ancestors.include?(Stunt::Double).should be_true
    end
    it "should include a reference to the stunt method singleton" do
      TestClass.__stunt__.should == StuntMethods
    end
  end
  
  describe "#new" do
    it "should return an instance of the original class name" do      
      TestClass.new.itself.class.should == TestClass
    end
    it "should return an instance of Stunt::Double or descendent" do
      TestClass.new.itself.should be_a_kind_of Stunt::Double
    end
    it "should accept arguments to the constructor" do
      TestClassWithArgument.new(true).itself.should be_a_kind_of Stunt::Double
    end
    it "should create an instance of StuntMethods" do
      TestClass.new.__stunt__.should be_a_kind_of StuntMethods
    end
  end
  
  describe "#_method_is_proxied_? [instance method]" do
    it "should return true for an instance method declared in the current mapped class" do
      TestClass._method_is_proxied_?(:some_method, true).should be_true
    end
    it "should return true for an instance method declared in a mapped ancestor class" do
      ChildClass._method_is_proxied_?(:some_method, true).should be_true
    end
    it "should return false for a method declared in an unmapped ancestor" do
      TestClass._method_is_proxied_?(:object_id, true).should be_false
    end
    it "should return false for an unsupported method" do
        TestClass._method_is_proxied_?(:not_a_method, true).should be_false
    end
  end
    
  describe "#_method_is_proxied_? [class method]" do
    it "should return true for a class method declared in the current mapped class" do
      TestClass._method_is_proxied_?(:some_class_method).should be_true
    end
    it "should return true for a class method declared in a mapped ancestor class" do
      ChildClass._method_is_proxied_?(:some_class_method).should be_true
    end
    it "should return false for a class method declared in an unmapped ancestor" do
      TestClass._method_is_proxied_?(:class_parent_method).should be_false
      TestClass._method_is_proxied_?(:class).should be_false
    end
    it "should return false for an unsupported method" do
        TestClass._method_is_proxied_?(:not_a_method).should be_false
    end
  end
    
  describe "#method_missing"

    context "for instance methods" do
      it "should raise an error if no instance method of the given name is found on the original class" do
        lambda { 
          TestClass.new.not_a_method
        }.should raise_error
      end
      it "should not raise an error if an instance method of the given name is found on the original class" do
        lambda {
          TestClass.new.some_method
        }.should_not raise_error
      end
      it "should return a new Stunt::Double instance for methods declared in a stunt-mapped class" do
        TestClass.new.some_method.itself.should be_a_kind_of(Stunt::Double)
      end
      it "should call _resolve_ before passing the result to a non-mapped method" do
        obj = TestClass.new
        obj._without_resolve_ {|o| o.should_receive(:_resolve_)}
        obj.to_s
      end
      it "should not respond to methods not defined in a mapped class" do
        lambda {
          TestClass.new.parent_method
        }.should raise_error
      end
      it "a subclass should return a Stunt::Double of the same subclass as itself" do
        JSTestClass.ancestors.include?(Stunt::JavaScript::Double).should be_true
        JSTestClass.new.js_method.itself.should be_a_kind_of(Stunt::JavaScript::Double)
      end
      it "should reference the invoking object" do
        obj = TestClass.new
        obj.some_method._invoking_object_.itself.should == obj.itself
      end
      it "should reference the invoking method" do
        obj = TestClass.new
        obj.some_method._invoking_method_.should == :some_method
      end
      it "should reference any passed arguments" do
        obj = TestClass.new
        obj.some_method(1,2,3)._invoking_arguments_.should == [1,2,3]
      end
      it "should create an instance of a specific proxied class when the return class of the previous method is indicated" do
        InvokingObjectClass.new.get_test_object.itself.should be_a_kind_of TestClass
        InvokingObjectClass.new.get_test_object.get_another.itself.should be_a_kind_of AnotherClass
      end
      it "should allow a supported method call when the return class of the previous method is indicated" do
        lambda {
          InvokingObjectClass.new.get_test_object.some_method
        }.should_not raise_error
      end
      it "should error on an unsupported method call when the return class of the previous method is indicated" do
        lambda {
          InvokingObjectClass.new.get_test_object.not_a_method
        }.should raise_error
      end
      it "should store the most recently created unresolved Stunt::Double object in Stunt::Base (class variable)" do
        obj1 = TestClass.new
        Stunt::Base.current_chain_end.itself.should == obj1
        obj2 = TestClass.new.some_method
        Stunt::Base.current_chain_end.itself.should == obj2
      end
      it "should trigger a call to the _resolve_ method of a previous unresolved Stunt::Double" do
        obj = TestClass.new
        obj._without_resolve_ {|o| o.should_receive(:_resolve_)}
        AnotherClass.new
      end
      it "should mark a previous unresolved Stunt::Double as resolved" do
        obj = TestClass.new
        obj._is_resolved_.should be_false
        AnotherClass.new
        obj._is_resolved_.should be_true
      end
      it "should not resolve a previous Stunt::Double in the same method chain" do
        obj = InvokingObjectClass.new.get_test_object
        obj._is_resolved_.should be_false
        obj._invoking_object_._is_resolved_.should be_false
      end      
    end
  
    context "for class methods" do
      it "should raise an error if no class method of the given name is found on the original class" do
        lambda { TestClass.not_a_method }.should raise_error
      end
      it "should not raise an error if a class method of the given name is found on the original class" do
        lambda { TestClass.some_class_method }.should_not raise_error
      end
      it "should return a new Stunt::Double instance" do
        TestClass.some_class_method.itself.should be_a_kind_of(Stunt::Double)
      end
      it "should not respond to methods not defined directly in a mapped class" do
        lambda {
          TestClass.class_parent_method
        }.should raise_error
      end
      it "a subclass should return a Stunt::Double of the same subclass as itself" do
        JSTestClass.ancestors.include?(Stunt::JavaScript::Double).should be_true
        JSTestClass.js_class_method.itself.should be_a_kind_of(Stunt::JavaScript::Double)
      end
      it "should reference the invoking class" do
        TestClass.some_class_method._invoking_object_.should == TestClass
      end
      it "should reference the invoking class method" do
        TestClass.some_class_method.itself._invoking_method_.should == :some_class_method
      end
      it "should reference any passed arguments" do
        TestClass.some_class_method(1,2,3)._invoking_arguments_.should == [1,2,3]
      end
      it "should create an instance of a specific proxied class when the return class of the previous method is indicated" do
        InvokingObjectClass.class_get_test_object.itself.should be_a_kind_of TestClass
      end
      it "should allow a supported method call when the return class of the previous method is indicated" do
        lambda {
          InvokingObjectClass.class_get_test_object.some_method
        }.should_not raise_error
      end
      it "should error on an unsupported method call when the return class of the previous method is indicated" do
        lambda {
          InvokingObjectClass.class_get_test_object.not_a_method
        }.should raise_error
      end
      it "should store the most recently created unresolved Stunt::Double object in Stunt::Base (class variable)" do
        obj1 = TestClass.some_class_method
        Stunt::Base.current_chain_end.itself.should == obj1
        obj2 = TestClass.some_class_method
        Stunt::Base.current_chain_end.itself.should == obj2
      end
      it "should trigger a call to the _resolve_ method of a previous unresolved Stunt::Double" do
        obj = TestClass.new
        obj._without_resolve_ {|o| o.should_receive(:_resolve_)}
        AnotherClass.some_class_method
      end
      it "should mark a previous unresolved Stunt::Double as resolved" do
        obj = TestClass.new
        obj._is_resolved_.should be_false
        AnotherClass.some_class_method
        obj._is_resolved_.should be_true
      end
    end
    
    describe "#_resolve_" do
      it "should mark the double as resolved" do
        obj = TestClass.new
        obj._is_resolved_.should be_false
        obj._resolve_
        obj._is_resolved_.should be_true
      end
    end
  
end


  
