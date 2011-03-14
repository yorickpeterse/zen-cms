#:nodoc:
module Settings
  #:nodoc:
  module Liquid
    ##
    # Tag that can be used to retrieve the values of the given setting.
    # Using this tag couldn't be easier:
    #
    #     {% settings "website_name" %}
    #
    # It's not required to specify quotes as setting keys don't contain
    # spaces but it's generally considered a good practice to do so anyway.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Setting < ::Liquid::Tag
      include ::Zen::Liquid::General
      
      ##
      # Constructor method is called when a new instance of this tag
      # is created. The variable "key" is the key name of the setting
      # who's value should be retrieved. This argument is always required.
      #
      # @author Yorick Peterse
      # @param  [String] tag_name The name of the tag that was called.
      # @param  [String] arguments All additional arguments passed as a string.
      # @param  [String] html The HTML inside the block.
      # @since  0.1
      #
      def initialize(tag_name = 'setting', key = '', markup = '')
        super
        
        @key = key.gsub('"', '').gsub("'", '')
      end
      
      ##
      # Renders the tag.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def render(context)
        setting = ::Settings::Models::Setting[:key => @key]

        if !setting.nil?
          if setting.value.nil? or setting.value.empty?
            @setting_value = setting.default
          else
            @setting_value = setting.value
          end
        end

        return @setting_value.to_s
      end
    end
  end
end
