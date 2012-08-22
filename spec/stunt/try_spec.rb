require 'spec_helper'

def func
"function Func() {
}"
end


class X
  def self.y
    Y.new
  end
end


class Y
  def z
    set_trace_func proc { |event, file, line, id, binding, classname|
      if event == 'line'
       puts "#{classname}:#{line}"
      end
    }
    10
  end
end

describe "this" do
  it "that" do
    a = X.y.z
    set_trace_func nil
  end
end