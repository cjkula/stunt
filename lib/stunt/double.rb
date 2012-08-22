class StuntMethods
  attr_reader :double
  def initialize(double)
    @double = double
  end
  def do_not_resolve_count
    double._do_not_resolve_count_ || 0
  end
  def do_not_resolve_count=(count)
    double._do_not_resolve_count_ = count
  end
  def do_not_resolve?
    do_not_resolve_count > 0
  end
  def _do_not_resolve_incr_
    do_not_resolve_count += 1
  end
  def _do_not_resolve_decr_
    do_not_resolve_count = (do_not_resolve_count == 0) ? 0 : do_not_resolve_count - 1
  end
end

class Stunt::Double
  
  # alias :_true_class_ :class
  
  DO_NOT_OVERRIDE = [:_true_class_, :initialize, :method_missing, :inspect]
  
  self.instance_methods.each do |meth|
    unless DO_NOT_OVERRIDE.include?(meth.to_sym)
      define_method(meth.to_sym) do |*args|
        if __stunt__.do_not_resolve?
          super
        else
          _resolve_
          _resolved_value_.send(meth.to_sym, *args)
        end
      end
    end
  end
      
  extend Stunt::Helpers
  
  attr_accessor :_do_not_resolve_count_
  
  def initialize(*args) # accept anything
    @__stunt__ = _true_class_.__stunt__.new(self)
    _true_class_._language_module_.set_current_chain_end(self)  # store the end of the chain in the base class
    self._invoking_object_ = _true_class_  # default assumption
    self._invoking_method_ = :new          # default assumption
    self._invoking_arguments_ = args
  end
  
  def method_missing(meth, *args)
    _true_class_._do_proxy_method_(self, meth, *args)
  end
    
  def self.method_missing(meth, *args)
    _do_proxy_method_(nil, meth, *args) rescue super
  end
  
  def self.__stunt__
    StuntMethods
  end
  attr_reader :__stunt__
  
  
  
  
  
  attr_accessor :_invoking_object_, :_invoking_method_, :_invoking_arguments_
  attr_accessor :_is_resolved_, :_resolved_value_
  
  def _true_class_
    _without_resolve_ { |obj| obj.class }
  end
  
  # def __stunt__.do_not_resolve?
  #   _do_not_resolve_count_ > 0
  # end
  # 
  # def _do_not_resolve_count_
  #   @_do_not_resolve_count_ || 0
  # end
  #   
  # def _do_not_resolve_incr_
  #   @_do_not_resolve_count_ = _do_not_resolve_count_ + 1
  # end
  # 
  # def _do_not_resolve_decr_
  #   count = _do_not_resolve_count_
  #   @_do_not_resolve_count_ = (count == 0) ? 0 : count - 1
  # end
  
  def _without_resolve_
    _do_not_resolve_incr_
    result = block_given? ? yield(self) : nil
    _do_not_resolve_decr_
    result
  end
    
  def self._do_proxy_method_(instance, meth, *args)
    if _method_is_proxied_?(meth, instance)
      if instance
        instance._do_not_resolve_incr_
      end
      return_classes = instance ? method_return_classes : class_method_return_classes
      if (return_class = return_classes[meth.to_sym])
        obj = Object.const_get(return_class.to_sym).new(*args) # created class-typed proxy object
      else
        obj = _language_module_.double_class.new(*args)    # create generic proxy object
      end
      # store references back to invoking object to create the proxied method chain
      obj._invoking_object_ = instance || self
      obj._invoking_method_ = meth
      if instance
        instance._do_not_resolve_decr_
      end
      # return the object
      obj
    elsif instance
      instance._resolve_and_send_(meth, *args)
    else
      raise
    end
  end
  
  def self._proxied_class_
    defined?(self::StuntProxiedClass) ? self::StuntProxiedClass : nil
  end
  
  def self._method_is_proxied_?(meth, instance=nil)
    cls = self._proxied_class_
    begin
      if (instance ? cls.instance_methods(false) : cls.methods(false)).find{|m| m.to_s == meth.to_s}
        return _language_module_.proxied_class?(cls)
      end
    end while (cls = cls.superclass)
    false
  end  
  
  def _resolve_and_send_(meth, *args)
    if __stunt__.do_not_resolve?
      raise "#{self._true_class_} instance does not respond to #{meth}" if !respond_to?(meth)
      send(meth, *args)
    else
      _resolve_
      _resolved_value_.send(meth, *args)
    end
  end
  
  def _resolve_
    _without_resolve_ do |obj|
      chain_end = _true_class_._language_module_.current_chain_end
      if chain_end && (chain_end._without_resolve_ {|o| o == obj})
        obj.class._language_module_.set_current_chain_end(nil)
      end
    end
    self._is_resolved_ = true
    _resolved_value_
  end
  
  def self._language_module_
    Stunt::Base
  end

end