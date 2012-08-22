class Stunt::Base
  
  # @@do_resolve = true
    
  # map one -- or a list -- of classes into Stunt::Double classes
  def self.map!(*target_classes)
    target_classes.flatten.each do |target_class|
      map_one!(target_class)
    end
  end
    
  private
  
  # Map one class into a Stunt::Double class
  def self.map_one!(original_class)
    raise "Expected a kind of Class, instead got a kind of #{original_class.class}." unless original_class.is_a?(Class)
    # Splitting up the namespace chain and cycling through to get the constant one level below the target class.
    #   ... Is there is easier way to do this? (Keeping in mind maintaining 1.8.x compatibility.)
    chain = original_class.to_s.split('::')
    class_sym = chain.pop.to_sym
    mod = Object
    while chain.size > 0
      mod = mod.const_get(chain.shift)
    end
    # create the double
    double_class = Class.new(self.double_class)
    # put reference to the original into the double
    double_class.const_set('StuntProxiedClass', original_class)
    # store class in list of proxied classes
    (@proxied_classes ||= []) << original_class.to_s
    # Undefine the original class to surpress warnings
    mod.send(:remove_const, class_sym) if mod.const_defined?(class_sym)
    # Redefine as a child class of Stunt::Double
    mod.const_set(class_sym, double_class)
  end
  
  def self.double_class
    Stunt::Double # Doubling class to be overridden in language-specific subclass
  end
  
  def self.current_chain_end
    defined?(@@current_chain_end) ? @@current_chain_end : nil
  end
  
  def self.set_current_chain_end(object)
    # if there is an existing chain and it hasn't been already marked to not resolve...
    if current_chain_end && !current_chain_end.__stunt__.do_not_resolve?
      # wrap it so it won't resolve
      current_chain_end._without_resolve_ do |chain_end|
        # if it is different than the new object and hasn't already been resolved...
        if current_chain_end != object && !current_chain_end._is_resolved_
          # resolve it
          current_chain_end._resolve_
        end
      end
    end
    # in any case, assign new object to chain end
    @@current_chain_end = object
  end
    
  def self.proxied_classes
    @proxied_classes || []
  end
  
  def self.proxied_class?(klass)
    @proxied_classes.include?(klass.to_s)
  end
  
end