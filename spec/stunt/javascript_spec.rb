require 'spec_helper'

class TestClass
  def some_method; end
end

def jsTestClass
"function TestClass(value) { 
    window.testFlag = true;
    this.value = value;
}\n"
end

module SomeNamespace
  class NamespacedClass; end
end

def jsClassContainer
"window.SomeNamespace = { 
    NamespacedClass: function() { 
        window.testFlag = true;
    } 
}\n"
end

def jsSetFlag(value)
  "window.testFlag = #{value.to_json};\n"
end

def jsGetFlag
  page.evaluate_script("window.testFlag")
end

Stunt::JavaScript.map! TestClass, SomeNamespace::NamespacedClass

describe "JavaScript language module" do
  
  describe "{object_class}.new" do
    before(:each) do
      page.execute_script(jsTestClass + jsClassContainer + jsSetFlag(false))
      Stunt::JavaScript.add_info_to_prototypes(true)
    end
    it "should generate the JavaScript to construct a new object" do
      TestClass.new._to_javascript_.should == "new TestClass()"
    end
    it "should run the javascript constructor method when resolved" do
      TestClass.new._resolve_
      jsGetFlag.should == true
    end
    it "should run the javascript constructor method for a namespaced object" do
      SomeNamespace::NamespacedClass.new._resolve_
      jsGetFlag.should == true
    end
    it "should store the name of the ruby class in each prototype" do
      page.evaluate_script('TestClass.prototype._full_class_').should == 'TestClass'
      page.evaluate_script('new TestClass()._full_class_').should == 'TestClass'
      page.evaluate_script('SomeNamespace.NamespacedClass.prototype._full_class_').should == 'SomeNamespace.NamespacedClass'
      page.evaluate_script('new SomeNamespace.NamespacedClass()._full_class_').should == 'SomeNamespace.NamespacedClass'      
    end
    it "should return a proxy object double" do
      TestClass.new.should be_a_kind_of TestClass
    end
    it "should return incrementing object ids for class instances" do
      id1 = TestClass.new['__id__']
      (TestClass.new['__id__'] - id1).should == 1
    end
    it "should return incrementing object ids for namespaced class instances" do
      id1 = SomeNamespace::NamespacedClass.new['__id__']
      (SomeNamespace::NamespacedClass.new['__id__'] - id1).should == 1
    end
    it "should add an object reference in the class when returning a mapped object" do
      id = TestClass.new['__id__']
      page.evaluate_script('TestClass.prototype._stunt_instances_.length').should == id + 1
      id2 = TestClass.new['__id__']
      page.evaluate_script('TestClass.prototype._stunt_instances_.length').should == id2 + 1
      id2.should == id + 1
    end
    it "should render a resolved object into JavaScript by reference to the class listing" do
      obj = TestClass.new._resolve_
      id = obj['__id__']
      obj._to_javascript_.should == "TestClass.prototype._stunt_instances_[#{id}]"
    end
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
  end
  
  describe "#_find_or_create_by_id_" do
    it "should create a new proxy object" do
      TestClass._find_or_create_by_id_(1).itself.class.should == TestClass
    end
    it "should create a new proxy object with the specified id" do
      TestClass._find_or_create_by_id_(10).itself._stunt_id_.should == 10
    end
    it "should add a new object to the class's list of instances" do
      obj = TestClass._find_or_create_by_id_(5)
      TestClass._class_instances_[5].itself.should == obj
    end
    it "should find an existing object in the list of class instances" do
      TestClass._find_or_create_by_id_(8)
      obj = TestClass._class_instances_[8]
      TestClass._find_or_create_by_id_(8).itself.should == obj
    end
  end
  
end