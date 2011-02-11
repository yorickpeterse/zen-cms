##
# Language pack that provides a translated set of messages used when validating models.
#
# @author Yorick Peterse
# @since  0.1
# 
Zen::Language.translation 'zen_models' do |lang|
  lang.exact_length = lambda do |length|
    "This field is not exactly #{length} characters long."
  end
  
  lang.format   = "This field's format is invalid."
  lang.includes = lambda do |arg|
    "This field's value is not in the range or set of #{arg.inspect}"
  end

  lang.integer      = "This field's value is not a number."
  lang.length_range = "This field's value is either too long or too short."

  lang.max_length   = lambda do |length|
    "This field's value may not be longer than #{length} characters."
  end

  lang.min_length   = lambda do |length|
    "This field's value may not be shorter than #{length} characters."
  end
  
  lang.not_string   = lambda do |type|
    "This field's value is not a valid #{type}."
  end
  
  lang.numeric = "This field's value is not numeric."
  lang.type    = lambda do |type|
    "This field's value is not a #{type}"
  end
  
  lang.presence = "This field's value is required."
  lang.unique   = "This field's value is already taken."
end
