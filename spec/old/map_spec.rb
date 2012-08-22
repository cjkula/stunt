require 'spec_helper'

describe "testing" do
  it "should js" do
    page.execute_script "alert('hello');"
  end
end

### SAMPLE CLASSES TO TEST AGAINST ###

class ParentClass # without the proxy code mixin itself
  def self.some_parent_class_method
    'some_parent_class_method (original)'
  end
  def some_parent_method
    'some_parent_instance_method (original)'
  end
end

class MyClass < ParentClass
  attr_reader :test1, :number, :two_words, :a_lot_of_nifty_words
  attr_writer :writeable, :an_attribute, :other
  attr_accessor :accessible, :value
  class << self; attr_accessor :some_class_property; end
  def self.some_class_method
    'some_class_method (original)'
  end
  def self.class_typed_method
    'class typed method'
  end
  def some_method(*args)
    'some_instance_method (original)'
  end
  def typed_method(*args)
  end
end

class OtherClass
  attr_writer :another_attribute
  def other_class_method(*args)
  end
end

### EXTEND THE CLASSES WITH THE MAP ###

class MyClass
  extend JavascriptProxy
  attr_writer :writer_defined_with_proxy
  attr_accessor :accessor_defined_with_proxy
  proxify
  method_output_class :typed_method => OtherClass,
                      :an_attribute => OtherClass,
                      :other => OtherClass
  class_method_output_class :class_typed_method => OtherClass
end

class OtherClass
  extend JavascriptProxy
  proxify
end

module MyClassContainer
  class MyContainedClass
    extend JavascriptProxy
    proxify
  end
end

describe "Stunt::Javascript#map!" do
  
  describe "proxy JavaScript variables" do
    it "should have a window object designated in which to store ad hoc references to objects of the class" do
      MyClass.test_obj_reference_container.should == 'window.TestObjects'
    end
  end
  
  # describe "{object_class}.new" do
  #   before(:each) do
  #     page.execute_script('function MyClass(value){window.didIt = true;this.value=value}')
  #     page.execute_script('window.MyClassContainer={MyContainedClass:function(){window.didIt = true;}}')
  #     page.execute_script('window.didIt = false;')
  #   end
  #   it "should create the same class of object" do
  #     MyClass.new.should be_a_kind_of(MyClass)
  #   end
  #   it "should create the same class of object for contained classes" do
  #     MyClassContainer::MyContainedClass.new.should be_a_kind_of(MyClassContainer::MyContainedClass)
  #   end
  #   it "should run the javascript constructor method" do
  #     MyClass.new
  #     page.evaluate_script('window.didIt').should == true
  #   end
  #   it "should run the javascript constructor method for a contained object" do
  #     MyClassContainer::MyContainedClass.new
  #     page.evaluate_script('window.didIt').should == true
  #   end
  #   it "should add a javascript reference variable" do
  #     page.execute_script('window.TestObjects = [1];')
  #     MyClass.new
  #     page.evaluate_script('window.TestObjects.length').should == 2
  #   end
  #   it "should create the reference container namespace if necessary" do
  #     MyClass.new
  #     page.evaluate_script('window.TestObjects.length').should == 1
  #   end
  #   it "can return the object reference variable index" do
  #     MyClass.new.test_object_index.should == 0
  #     MyClass.new.test_object_index.should == 1
  #   end
  #   it "can return the full string for the reference variable" do
  #     MyClass.new.test_object_variable.should == "window.TestObjects[0]"
  #     MyClassContainer::MyContainedClass.new.test_object_variable.should  == "window.TestObjects[1]"
  #   end
  #   it "should return the object's reference variable when converting object to string" do
  #     my_object = MyClass.new
  #     "#{my_object}".should == "window.TestObjects[0]"
  #   end
  #   it "should set the JS object's testObjectId property" do
  #     my_obj = MyClass.new
  #     my_second_obj = MyClassContainer::MyContainedClass.new
  #     page.evaluate_script("#{my_obj}.testObjectId").should == 0
  #     page.evaluate_script("#{my_second_obj}.testObjectId").should == 1
  #   end
  #   it "should put a reference to itself at the index in the global variable $js_test_objects" do
  #     MyClass.new; MyClass.new; MyClass.new; obj = MyClass.new
  #     $js_test_objects[3].should == obj
  #   end
  #   it "should accept arguments to the constructor" do
  #     MyClass.new(1000).value.should == 1000
  #   end
  # end
  # 
  # describe "instance methods" do
  #   before(:each) do
  #     page.execute_script('function MyClass(){}')
  #   end
  #   it "should be overriden to return a javascript method chain object" do
  #     MyClass.new.some_method.really_should be_a_kind_of JavascriptMethodChain
  #   end
  #   it "should not be overriden when inherited" do
  #     MyClass.new.some_parent_method.should == 'some_parent_instance_method (original)'
  #   end
  # end
  # 
  # describe "class methods" do
  #   it "should override class methods to return a javascript method chain object" do
  #     MyClass.some_class_method.really_should be_a_kind_of JavascriptMethodChain
  #   end
  #   it "should not be overriden when inherited" do
  #     MyClass.some_parent_class_method.should == 'some_parent_class_method (original)'
  #   end
  #   it "should record the method call" do
  #     MyClass.some_class_method._chain_method_name.should == "some_class_method"
  #   end
  #   it "should record the arguments" do
  #     MyClass.some_class_method(1,2,3)._chain_arg_list.should == [1,2,3]
  #   end
  #   it "should set a single-level method chain to point back to its invoking object" do
  #     MyClass.some_class_method._chain_invoking_object.should == MyClass
  #   end
  #   it "should recognize a class method as a call to the prototype" do
  #     MyClass.some_class_method.to_s.should == 'MyClass.prototype.someClassMethod()'
  #   end
  #   it "should recognize a class writer as a call to a prototype property" do
  #     MyClass.some_class_property.to_s.should == 'MyClass.prototype.someClassProperty'
  #   end
  #   it "should raise an error if method does not exist on class" do
  #     lambda {
  #       MyClass.some_nonexisting_property
  #     }.should raise_error
  #   end
  #   it "should allow a class be specified to indicate data type of method output" do
  #     MyClass.class_typed_method._represented_class.should == OtherClass
  #   end
  #   it "should restrict method calls to those enumerated in the output class" do
  #     lambda {
  #       MyClass.class_typed_method.other_class_method
  #     }.should_not raise_error
  #     lambda {
  #       MyClass.class_typed_method.not_a_class_method
  #     }.should raise_error
  #   end
  # end
  #   
  # describe "Method chaining" do
  #   before(:each) do
  #     page.execute_script('function MyClass(){
  #                             this.test1 = function(){
  #                               return {
  #                                 test2: function(){return "result";}
  #                               }
  #                             }
  #                             this.number = function(){return 42;}
  #                             this.twoWords = function(){return true;}
  #                             this.aLotOfNiftyWords = function(){return true;}
  #                           }')
  #   end
  #   it "should return a proxy object if no following chain" do
  #     MyClass.new.should be_a_kind_of MyClass
  #   end
  #   it "should return a javascript method chain object if any method call(s)" do
  #     MyClass.new.some_method.really_should be_a_kind_of JavascriptMethodChain
  #     MyClass.new.some_method.second_call.third_call.really_should be_a_kind_of JavascriptMethodChain
  #   end
  #   it "should record the method call" do
  #     MyClass.new.some_method._chain_method_name.should == "some_method"
  #   end
  #   it "should record the arguments" do
  #     MyClass.new.some_method(1,2,3)._chain_arg_list.should == [1,2,3]
  #   end
  #   it "should set a single-level method chain to point back to its invoking object" do
  #     obj = MyClass.new
  #     obj.some_method._chain_invoking_object.should == obj
  #   end
  #   it "should translate underscore-style methods into JavaScript variable case" do
  #     MyClass.new.two_words.to_s.should == 'window.TestObjects[0].twoWords()'
  #     MyClass.new.a_lot_of_nifty_words.to_s.should == 'window.TestObjects[1].aLotOfNiftyWords()'
  #   end
  #   it "should render a method chain as a string of function calls" do
  #     MyClass.new.some_method.to_s.should == 'window.TestObjects[0].someMethod()'
  #     MyClass.new.some_method.other_method.to_s.should == 'window.TestObjects[1].someMethod().otherMethod()'
  #   end
  #   it "should send the method chain to javascript for evaluation before passing to 'should'" do
  #     MyClass.new.number.should == 42
  #     MyClass.new.test1.test2.should == 'result'
  #   end
  #   it "should be able to save the method chain in a variable and then evaluate when passed to 'should'" do
  #     chain1 = MyClass.new.number
  #     chain1.should == 42
  #     chain2 = MyClass.new.test1.test2
  #     chain2.should == 'result'
  #   end
  #   it "should send the method chain to javascript for evaluation before passing to 'should_not'" do
  #     chain = MyClass.new.number
  #     page.should_receive(:evaluate_script).with('window.TestObjects[0].number()').and_return(10)
  #     chain.should_not == 20
  #   end
  #   it "should include argument lists containing numbers in the method chain" do
  #     MyClass.new.some_method(1,-2,3.4).to_s.should == 'window.TestObjects[0].someMethod(1,-2,3.4)'
  #   end
  #   it "should include argument lists containing strings in the method chain" do
  #     MyClass.new.some_method('a',"b").to_s.should == 'window.TestObjects[0].someMethod("a","b")'
  #   end
  #   it "should include objects referenced in method chain arguments as through their js ref variable" do
  #     obj1 = MyClass.new
  #     MyClass.new.some_method(obj1).to_s.should == 'window.TestObjects[1].someMethod(window.TestObjects[0])'
  #   end
  #   it "should include method chains referenced in arguments" do
  #     obj1 = MyClass.new.some_method(10)
  #     MyClass.new.some_method(obj1).to_s.should == 'window.TestObjects[1].someMethod(window.TestObjects[0].someMethod(10))'
  #   end
  #   it "should include nil/null as argument"
  #   it "should include arrays referenced in arguments"
  #   it "should include hashes referenced in arguments"
  #   it "should include nested arrays referenced in arguments"
  #   it "should include nested hashes referenced in arguments"
  #   it "should include nil/null inside other structures in arguments"
  # end
  #   
  # describe "class typing results of instance methods" do
  #   before(:each) do
  #     page.execute_script('function MyClass(){}')
  #   end
  #   it "should recognize attribute writer methods as representing attributes, not functions" do
  #     MyClass.new.writeable.to_s.should == 'window.TestObjects[0].writeable'
  #     MyClass.new.accessible.to_s.should == 'window.TestObjects[1].accessible'
  #   end
  #   it "should allow reader methods to be designated in the proxy definition" do
  #     MyClass.new.writer_defined_with_proxy.to_s.should == 'window.TestObjects[0].writerDefinedWithProxy'
  #     MyClass.new.accessor_defined_with_proxy.to_s.should == 'window.TestObjects[1].accessorDefinedWithProxy'
  #   end
  #   it "should allow a class be specified to indicate data type of method output" do
  #     MyClass.new.typed_method._represented_class.should == OtherClass
  #   end
  #   it "should restrict method calls to those enumerated in the output class" do
  #     lambda {
  #       MyClass.new.typed_method.other_class_method
  #     }.should_not raise_error
  #     lambda {
  #       MyClass.new.typed_method.not_a_class_method
  #     }.should raise_error
  #   end
  #   it "should include arguments to typed methods in javascript output" do
  #     MyClass.new.typed_method('a',"b").other_class_method(1,2,3).to_s.should == 'window.TestObjects[0].typedMethod("a","b").otherClassMethod(1,2,3)'
  #   end
  #   it "should process attribute methods in the middle and the end of output" do
  #     MyClass.new.an_attribute.other_class_method.to_s.should == 'window.TestObjects[0].anAttribute.otherClassMethod()'
  #     MyClass.new.other.another_attribute.to_s.should == 'window.TestObjects[1].other.anotherAttribute'
  #   end
  # end
  
end



