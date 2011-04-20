#:nodoc:
module Settings
  #:nodoc:
  module Model
    ##
    # Model that represents a single setting. This model is also used to retrieve
    # all possible values for a certain settngs. This is done by calling a method
    # that matches the format get_SETTING-NAME_values. For example, a setting named "theme"
    # would result in a call to Settings::Model::Setting#get_theme_values.
    #
    # In order to add new method you'll have to monkey patch this model as following:
    #
    #     class Setting < Sequel::Model
    #       def self.get_my_setting_values
    #         # Do something and return it...
    #       end
    #     end
    #
    # @author Yorick Peterse
    # @since  0.1
    # @todo   Monkey patching a model in order to get possible values isn't the nicest way
    # of solving this problem but it does allow for extra flexibility. It might be a good
    # idea to refactor this and put it in it's own class/plugin/whatever.
    #
    class Setting < Sequel::Model

      ##
      # Retrieves all settings and returns them as a key/value hash.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @return [Hash] key/value hash containing all settings and their values.
      #
      def self.get_settings
        settings = {}
        
        self.all.each do |s|
          if s.value.nil?
            value = s.default
          else
            value = s.value
          end
          
          settings[s.name.to_sym] = value
        end
        
        return settings
      end

    end
  end
end
