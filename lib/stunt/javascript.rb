class Stunt::JavaScript < Stunt::Base
  def self.add_info_to_prototypes(force=false)
    if !@_added_info_to_prototypes_ || force
      page.execute_script(stunt_evaluate_wrapper)
      proxied_classes.each do |cls|
        js_class = cls.gsub(/::/, '.')
        page.execute_script("#{js_class}.prototype._full_class_ = '#{js_class}';")
        page.execute_script("#{js_class}.prototype._stunt_instances_ = [null];") # null value inserted so ids can begin with 1
      end
      @_added_info_to_prototypes_ = true
    end
  end
  def self.stunt_evaluate_wrapper
    "window._stunt_evaluate_wrapper_ = function(evaluation) {
      if (evaluation._full_class_) {
        evaluation._stunt_instances_.push(evaluation);
        return {
          __class__: evaluation._full_class_,
          __id__:    evaluation._stunt_instances_.length - 1
        };
      }
      return evaluation;
    }\n"
  end
  def self.double_class
    Stunt::JavaScript::Double
  end
end

class Stunt::JavaScript::Double < Stunt::Double
  attr_accessor :_stunt_id_
  def _resolve_
    if !_is_resolved_
      _true_class_._language_module_.add_info_to_prototypes # if not already done
      value = page.evaluate_script("window._stunt_evaluate_wrapper_(#{self._to_javascript_})")
      if value['__class__']
        klass = _js_class_to_ruby_class_(value['__class__'])
        self._resolved_value_ = klass._find_or_create_by_id_(value['__id__'])
      else
        self._resolved_value_ = value
      end
    end
    super
  end
  def _js_class_to_ruby_class_(js_class)
    klass = Object
    js_class.split('.').each do |s|
      klass = klass.const_get(s.to_sym)
    end
    klass
  end
  def self._find_or_create_by_id_(id)
    @_class_instances_ ||= []
    obj = @_class_instances_[id]
    return obj if obj
    obj = self.new
    obj._stunt_id_ = id
    @_class_instances_[id] = obj
    obj
  end
  def self._class_instances_
    @_class_instances_
  end
  def self._to_javascript_
    self.to_s.gsub(/::/, '.')
  end
  def _to_javascript_
    invoker = _invoking_object_._to_javascript_
    meth = _javascript_case_(_invoking_method_)
    if @is_attribute
      raise "Attempted to pass arguments to a method defined as a writeable attribute" if _invoking_arguments_.length > 0      
      args = ''
    else
      args = '(' + _args_string_ + ')'
    end
    if !_invoking_object_.is_a?Class
      "#{invoker}.#{meth}#{args}"
    elsif meth == 'new'
      "new #{invoker}#{args}"
    else
      "#{invoker}.prototype.#{meth}#{args}"
    end
  end
  def _javascript_case_(method)
    method.to_s.gsub(/_(.)/){"#{$1.capitalize}"}
  end
  def _args_string_
    (_invoking_arguments_ || []).map do |arg|
      case arg
      when String
        arg.to_json  
      else
        arg.to_s
      end
    end.join(',')
  end
  def self._language_module_
    Stunt::JavaScript
  end
end

# $js_test_objects = [] unless defined?($js_test_objects)
# 
# class Stunt::JavaScript
#   def self.map!(*classes)
#     classes.flatten.each do |klass|
#       # class klass
#       #   extend JavascriptProxy
#       #   proxify
#       # end
#     end
#   end
# end

# 
# class JavascriptMethodChain
#   attr_accessor :_chain_invoking_object, :_chain_method_name, :_chain_arg_list, :_represented_class, :is_attribute
#   alias :really_should :should
#   alias :really_should_not :should_not
#   def initialize(invoking_object, method, *args)
#     @_chain_invoking_object = invoking_object
#     if method.to_s[-1,1] == '='
#       method = method.to_s.chop.to_sym
#       @is_attribute = true
#     end
#     @_chain_method_name = method
#     @_chain_arg_list = args
#     if invoking_object.is_a?Class
#       @_represented_class = invoking_object.class_method_output_classes[_chain_method_name.to_sym]
#     else
#       prev_represented_class = invoking_object._represented_class # get the class on which this method was called
#       if prev_represented_class
#         @_represented_class = prev_represented_class.method_output_classes[_chain_method_name.to_sym]  
#       end
#     end
#   end
#   def method_missing(meth, *args, &block)
#     send_meth = meth.to_s.match(/[^=]+/)[0]
#     if @_represented_class # class was been specified to enforce available functions / attributes
#       writer_meth = send_meth + '='
#       raise "Method :#{meth} not found for class #{@_represented_class}" unless @_represented_class.instance_methods.include?(send_meth)
#       # if there IS a writer method, send that to surpress function call parentheses
#       send_meth = writer_meth if @_represented_class.instance_methods.include?(writer_meth)
#     end
#     JavascriptMethodChain.new(self, send_meth, *args)
#   end
#   def _args_string
#     _chain_arg_list.map { |arg|
#       case arg
#       when String
#         arg.to_json  
#       else
#         arg.to_s
#       end
#     }.join(',')
#   end
#   def _javascript_case(method)
#     method.to_s.gsub(/_(.)/){"#{$1.capitalize}"}
#   end
#   def to_s
#     string = @_chain_invoking_object ? "#{@_chain_invoking_object}." : ''
#     string << 'prototype.' if @_chain_invoking_object.is_a?(Class)
#     string << _javascript_case(@_chain_method_name) 
#     if !@is_attribute
#       string << '(' + _args_string + ')'
#     elsif @_chain_arg_list.length > 0
#       raise "Attempted to pass arguments to a method defined as a writeable attribute"
#     end
#     string
#   end
#   def _evaluate
#     page.evaluate_script(self.to_s)
#   end
#   def should(*args)
#     _evaluate.should(*args)
#   end
#   def should_not(*args)
#     _evaluate.should_not(*args)
#   end
# end
# 
# module JavascriptProxy
#   def proxify
#     puts methods(false).sort.inspect
#     methods(false).each do |meth|
#       class_reader_meth = meth.match(/[^=]+/)[0]
#       class_writer_meth = class_reader_meth + '='
#       # only redefine if this is a writer method or if there is no writer method
#       if meth==class_writer_meth || !(methods.include?(class_writer_meth))
#         # redefine as a reader, i.e. without the equals sign
#         (class << self; self end).send :define_method, class_reader_meth do |*args| 
#           # but create the chain object with the writer flag to prevent function call parenthesis
#           JavascriptMethodChain.new(self, meth, *args)
#         end        
#       end
#     end
#     instance_methods(false).each do |meth|
#       reader_meth = meth.match(/[^=]+/)[0]
#       writer_meth = reader_meth + '='
#       # only redefine if this is a writer method or if there is no writer method
#       if meth==writer_meth || !(instance_methods.include?(writer_meth))
#         # redefine as a reader, i.e. without the equals sign
#         define_method reader_meth do |*args|
#           # but create the chain object with the writer flag to prevent function call parenthesis
#           JavascriptMethodChain.new(self, meth, *args)
#         end        
#       end
#     end
#     # extend ClassMethods
#     # include InstanceMethods
#   end
# end

# module JavascriptProxy::ClassMethods
#   def method_output_class(associations)
#     (@method_output_classes ||= {}).update(associations)
#   end    
#   def method_output_classes
#     @method_output_classes || {}
#   end
#   def class_method_output_class(associations)
#     (@class_method_output_classes ||= {}).update(associations)
#   end    
#   def class_method_output_classes
#     @class_method_output_classes || {}
#   end
#   def test_obj_reference_container
#     'window.TestObjects'
#   end
#   def _represented_class
#     self
#   end
#   def _to_javascript_string(with_prototype=nil)
#     self.to_s.gsub(/::/, '.') + (with_prototype ? '.prototype' : '')
#   end
# end

# module JavascriptProxy::InstanceMethods
#   def initialize(*args)
#     js_ref_container = self.class.test_obj_reference_container
#     js_class_name = self.class._to_javascript_string
#     page.execute_script("")
#     script = "(function(){
#                 var index, obj;
#                 #{js_ref_container} = #{js_ref_container} || [];
#                 index = #{js_ref_container}.length;
#                 obj = new #{js_class_name}(#{_args_to_string(args)});
#                 #{js_ref_container}[index] = obj;
#                 obj.testObjectId = index;
#                 return index;
#               })();"
#     @test_object_index = page.evaluate_script(script)
#     $js_test_objects[@test_object_index] = self
#   end
#   def _args_to_string(args)
#     args.map { |arg|
#       case arg
#       when String
#         arg.to_json  
#       else
#         arg.to_s
#       end
#     }.join(',')
#   end
#   def test_object_index
#     @test_object_index
#   end
#   def test_object_variable
#     "#{self.class.test_obj_reference_container}[#{@test_object_index}]"
#   end
#   def to_s
#     test_object_variable
#   end
#   def _represented_class
#     self.class
#   end
#   def method_missing(meth, *args, &block)
#     writer_method = meth.to_s + '='
#     if self.class.instance_methods.include? writer_method
#       JavascriptMethodChain.new(self, writer_method, *args)
#     else
#       raise "Method :#{meth} not found for object of class #{self.class}"
#     end
#   end
# end

