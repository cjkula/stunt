module Stunt::Helpers
  BAD_ARGUMENT_MESSAGE = "Expected a hash of method-to-return-class associations, instead got "
  def included
    raise "Incorrect usage 'include'; use 'extend Stunt::Helpers'."
  end
  def method_return_class(associations)
    (@method_return_classes ||= {}).update(_standardize_association_formats(associations))
  end
  def class_method_return_class(associations)
    (@class_method_return_classes ||= {}).update(_standardize_association_formats(associations))
  end
  def method_return_classes
    (_proxied_class_.method_return_classes rescue {}).update(@method_return_classes || {})
  end
  def class_method_return_classes
    (_proxied_class_.class_method_return_classes rescue {}).update(@class_method_return_classes || {})
  end
  private
  def _standardize_association_formats(associations)
    raise "#{BAD_ARGUMENT_MESSAGE}#{associations.inspect}" unless associations.is_a?(Hash)
    standardized = {}
    associations.each_pair do |method, klass|
      standardized[method.to_sym] = klass.to_s
    end
    standardized
  end
end
