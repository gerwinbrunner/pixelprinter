module StringProcessingFilter
  
  def handleize(input)
    input.to_s.to_handle
  end
  alias :handle :handleize
  
  # does to_handle first -- not the same as active_support camelcase!
  def camelize(input)
    input.to_s.to_handle.gsub(/-/,"_").camelize
  end
  alias :camelcase :camelize

end