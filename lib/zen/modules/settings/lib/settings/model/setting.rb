module Settings
  module Models
    ##
    # Model that represents a single setting. The Setting model
    # has to additional relations and doesn't use any plugins,
    # it only provides an additional method namely the get_settings()
    # method.
    #
    # @author Yorick Peterse
    # @since  0.1
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
          
          settings[s.key.to_sym] = value
        end
        
        return settings
      end
    end
    
  end
end
