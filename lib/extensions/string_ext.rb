class String
  # used in liquid filters
  def to_handle
    result = ActiveSupport::Inflector.transliterate(self)
                                                                                                                           
    result.downcase!
    
    # remove apostrophe and bracets
    result.gsub!(/[\'\"\(\)\[\]]/, '')

    # strip all non word chars
    result.gsub!(/\W/, ' ')

    # replace all white space sections with a dash
    result.gsub!(/\ +/, '-')

    # trim dashes
    result.gsub!(/(-+)$/, '')
    result.gsub!(/^(-+)/, '')
    
    result
  end
  
end