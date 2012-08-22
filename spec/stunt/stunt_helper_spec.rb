require 'spec_helper'

describe "Stunt::Helper" do

  before(:each) do
    Object.send(:remove_const, :TestClass) if Object.const_defined?(:TestClass)
    Object.const_set :TestClass, Class.new
    TestClass.extend Stunt::Helpers
    Object.send(:remove_const, :TestClass2) if Object.const_defined?(:TestClass2)
    Object.const_set :TestClass2, Class.new
    TestClass2.extend Stunt::Helpers
  end

  describe "#method_return_class" do
  
    it "should provide a 'method_return_class' helper method" do
      lambda {
        TestClass.method_return_class({})
      }.should_not raise_error
    end
    it "should associate a method symbol with an expected return class" do
      TestClass.method_return_class :some_method => Integer
      TestClass.method_return_classes[:some_method].should == "Integer"
    end
    it "should accept a string argument for the method name" do
      TestClass.method_return_class 'some_method' => Integer
      TestClass.method_return_classes[:some_method].should == "Integer"
    end
    it "should accept a string argument for the class name" do
      TestClass.method_return_class :some_method => "Integer"
      TestClass.method_return_classes[:some_method].should == "Integer"
    end
    it "should accept multiple associations on a single call" do
      TestClass.method_return_class :some_method => Float, 'some_other_method' => 'String'
      TestClass.method_return_classes[:some_method].should == "Float"
      TestClass.method_return_classes[:some_other_method].should == "String"
    end
    it "should add associations" do
      TestClass.method_return_class :some_method => Integer
      TestClass.method_return_class :some_other_method => String
      TestClass.method_return_classes[:some_method].should == "Integer"
      TestClass.method_return_classes[:some_other_method].should == "String"
    end
    it "should override previous associations" do
      TestClass.method_return_class :some_method => Integer
      TestClass.method_return_class 'some_method' => String
      TestClass.method_return_classes[:some_method].should == "String"
    end
    it "should retain associations after mapping" do
      TestClass.method_return_class :some_method => Integer
      TestClass.method_return_class :some_other_method => String
      Stunt::Base.map!(TestClass)
      TestClass.method_return_classes[:some_method].should == "Integer"
      TestClass.method_return_classes[:some_other_method].should == "String"
    end
    it "should add associations after mapping" do
      TestClass.method_return_class :some_method => Integer
      Stunt::Base.map!(TestClass)
      TestClass.method_return_class :some_other_method => String
      TestClass.method_return_classes[:some_method].should == "Integer"
      TestClass.method_return_classes[:some_other_method].should == "String"
    end
    it "should override associations after mapping" do
      TestClass.method_return_class :some_method => Integer
      Stunt::Base.map!(TestClass)
      TestClass.method_return_class :some_method => String
      TestClass.method_return_classes[:some_method].should == "String"
    end
  end


  describe "#class_method_return_class" do  
    it "should provide a 'class_method_return_class' helper method" do
      lambda {
        TestClass.class_method_return_class({})
      }.should_not raise_error
    end
    it "should associate a method symbol with an expected return class" do
      TestClass.class_method_return_class :some_class_method => TestClass2
      TestClass.class_method_return_classes[:some_class_method].should == "TestClass2"
    end
    it "should accept a string argument for the method name" do
      TestClass.class_method_return_class 'some_class_method' => TestClass2
      TestClass.class_method_return_classes[:some_class_method].should == "TestClass2"
    end
    it "should accept a string argument for the class name" do
      TestClass.class_method_return_class :some_class_method => "TestClass2"
      TestClass.class_method_return_classes[:some_class_method].should == "TestClass2"
    end
    it "should accept multiple associations on a single call" do
      TestClass.class_method_return_class :some_class_method => Float, 'some_other_class_method' => 'String'
      TestClass.class_method_return_classes[:some_class_method].should == "Float"
      TestClass.class_method_return_classes[:some_other_class_method].should == "String"
    end
    it "should add associations" do
      TestClass.class_method_return_class :some_class_method => Integer
      TestClass.class_method_return_class :some_other_class_method => String
      TestClass.class_method_return_classes[:some_class_method].should == "Integer"
      TestClass.class_method_return_classes[:some_other_class_method].should == "String"
    end
    it "should override previous associations" do
      TestClass.class_method_return_class :some_class_method => Integer
      TestClass.class_method_return_class 'some_class_method' => String
      TestClass.class_method_return_classes[:some_class_method].should == "String"
    end
    it "should retain associations after mapping" do
      TestClass.class_method_return_class :some_class_method => Integer
      TestClass.class_method_return_class :some_other_class_method => String
      Stunt::Base.map!(TestClass)
      TestClass.class_method_return_classes[:some_class_method].should == "Integer"
      TestClass.class_method_return_classes[:some_other_class_method].should == "String"
    end
    it "should add associations after mapping" do
      TestClass.class_method_return_class :some_class_method => Integer
      Stunt::Base.map!(TestClass)
      TestClass.class_method_return_class :some_other_class_method => String
      TestClass.class_method_return_classes[:some_class_method].should == "Integer"
      TestClass.class_method_return_classes[:some_other_class_method].should == "String"
    end
    it "should override associations after mapping" do
      TestClass.class_method_return_class :some_class_method => Integer
      Stunt::Base.map!(TestClass)
      TestClass.class_method_return_class :some_class_method => String
      TestClass.class_method_return_classes[:some_class_method].should == "String"
    end
  end
    
end
