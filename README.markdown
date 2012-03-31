PRE-RELEASE COMMIT: Here's some info, but there's not much to see in the files yet.

https://rubygems.org/gems/stunt
<pre>
gem install stunt --pre
</pre>

Maps Ruby object method chain addressing into corresponding JavaScript method chains.

<pre>
require 'stunt'

class MyClass
  def some_method
    'result'
  end
end

Stunt::Javascript.map!(MyClass)

describe "MyClass in JavaScript" do
	it "should get 'result'" do
		MyClass.new.some_method.should == 'result'
	end
end
</pre>

The test reads normally in Ruby, but behind the curtains, Stunt calls the Javascript constructor for MyClass, stores and returns a reference to that object, and then evaluates its corresponding method, i.e.

<pre>
window.TestObjects[0] = new MyClass();  // the index is returned and tracked in the Ruby proxy object
// ...
window.TestObjects[0].someMethod();     // underscore notation is translated to JavaScript-style names
</pre>

A whole lotta convention over configuration going on here. : )

This started off as a tool to assist in the development of Cipher (https://github.com/cjkula/cipher-lang), but I hope that others might be able to get some use out of it for different purposes.