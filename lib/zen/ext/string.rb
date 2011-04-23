##
# Extension to the string class provided by Ruby that provides the following 2 methods:
#
# * String.pluralize
# * String.singularize
#
# Note that these methods only work for English words, other languages such as Japanese
# or French aren't supported at this time (January, 2011). This snippet also doesn't cover
# every single english word, patches are welcome!
#
# @author Yorick Peterse, Michael Fellinger
# @since  1.0
#
class String
  ##
  # Constant containing all regular expressions for singular strings (that will be pluralized)
  # and their replacements.
  #
  # @since 1.0
  # 
  SingularToPlural = {
    /ss$/ => 'sses',
    /se$/ => 'ses',
    /sh$/ => 'shes',
    /ge$/ => 'ges',
    /ch$/ => 'ches',
    /ge$/ => 'ges',
    /g$/  => 'gs',

    # When the singular form ends in a voiceless consonant (other than a sibilant).
    # 
    # lap   => laps
    # cat   => cats
    # clock => clocks
    # cuff  => cuffs
    # death => deaths
    /ap$/ => 'aps',
    /at$/ => 'ats',
    /ck$/ => 'cks',
    /ff$/ => 'ffs',
    /th$/ => 'ths',
    
    # Most nouns ending in o preceded by a consonant also form their plurals by adding -es
    # 
    # hero    => heroes
    # potato  => potatoes
    # volcano => volcanoes or volcanos
    /o$/  => 'oes',
    
    # nouns ending in a y preceded by a consonant usually drop the y and add -ies
    #
    # cherry => cherries
    # lady   => ladies
    # ywzxvtsrqpnmlkjhgfdcb
    # 
    /([bcdfghjklmnpqrstvxzwy]+)y$/ => "\\1ies",
    
    # For all other words (i.e. words ending in vowels or voiced non-sibilants).
    # 
    # boy   => boys
    # girl  => girls
    # chair => chairs
    # quiz  => quizes
    /z$/  => 'zes',
    /y$/  => 'ys',
    /l$/  => 'ls',
    /r$/  => 'rs'
  }
  
  ##
  # Constant containing all regular expressions used to convert plural words to
  # singular words.
  #
  # @since 1.0
  #
  PluralToSingular = {
    /sses$/ => 'ss',
    /ses$/  => 'se',
    /shes$/ => 'sh',
    /ges$/  => 'ges',
    /ches$/ => 'ches',
    /ges$/  => 'ges',
    /aps$/  => 'ap',
    /ats$/  => 'at',
    /cks$/  => 'ck',
    /ffs$/  => 'ff',
    /ths$/  => 'th',
    /oes$/  => 'o',
    /ies$/  => 'y',
    /zes$/  => 'z',
    /ys$/   => 'y',
    /l$/    => 'ls',
    /r$/    => 'rs',
    /s$/    => ''
  }
  
  ##
  # Tries to convert a string to it's pluralized version. For example, "user" would
  # result in "users" and "quiz" will result in "quizes". This method will return
  # the pluralized string, use pluralize! to overwrite the current (singular) version
  # of the string with the pluralized one.
  #
  # @example
  #  
  #  "user".pluralize # => users
  #  "baby".pluralize # => babies
  #
  # @author Yorick Peterse, Michael Fellinger
  # @return [String] The pluralized version of the string.
  # @since  1.0
  #
  def pluralize
    string = self.dup
    
    SingularToPlural.each do |regex, replace|
      new_string = string.gsub(regex, replace)
      
      if new_string != string
        return new_string
      end
    end
    
    return string
  end
  
  ##
  # Converts the current string into a pluralized form and
  # overwrites the old value rather than returning it.
  #
  # @example
  #
  #  word = "user"
  #  word.pluralize! # => nil
  #
  #  puts word # => users
  #
  # @since 1.0
  #
  def pluralize!
    self.replace(self.pluralize)
  end
  
  ##
  # Tries to convert the current string into a singular version.
  #
  # @example
  #
  #  "users".singularize  # => user
  #  "babies".singularize # => baby
  #
  # @author Yorick Peterse
  # @return [String] a singular form of the string
  # @since  1.0
  #
  def singularize
    string = self.dup
    
    PluralToSingular.each do |regex, replace|
      new_string = string.gsub(regex, replace)
      
      if new_string != string
        return new_string
      end
    end
    
    return string
  end
  
  ##
  # Converts a plural string to it's singular form and replaces
  # the current value of the string with this singular version.
  #
  # @example
  #
  #  word = "users"
  #  word.singularize! # => nil
  #
  #  puts word # => user
  #
  # @since 1.0
  #
  def singularize!
    self.replace(self.singularize)
  end
end
