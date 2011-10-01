module Comments
  #:nodoc:
  class Plugin
    ##
    # A plugin that can be used to verify a comment against an external (or
    # internal) service to see if it's spam or ham.
    #
    # ## Usage
    #
    #     plugin(:anti_spam, engine, author, email, url, comment)
    #
    # Note that all variables are required. This is because certain anti-spam
    # systems may verify the name of the author or the entered Email address
    # besides just the comment. When using Defensio you're only required to set
    # the comment:
    #
    #     plugin(
    #       :anti_spam, :defensio, nil, nil, nil, 'Hello, this is a comment.'
    #     )
    #
    # ## Supported Systems
    #
    # Currently the plugin only supports Defensio, this engine requires the
    # setting "defensio_key" to contain a valid Defensio API key.
    #
    # ## Adding Systems
    #
    # Adding a system is done in two steps. First you should update the hash
    # {Comments::Plugin::AntiSpam::Registered} so that it includes your system.
    # The keys of this hash are symbols that match the name of the engine used
    # when calling the plugin() method. The values are the Gems to require (if
    # any). If your system doesn't require a gem simply set the value to nil.
    #
    # Once this has been done you should add a method to the class
    # {Comments::Plugin::AntiSpam} who's name matches the key set in the
    # Registered hash. If your anti-spam solution is called "cake" then you'd
    # do something like the following:
    #
    #     Comments::Plugin::AntiSpam::Registered[:cake] = 'cake-gem'
    #
    #     module Comments
    #       class Plugin
    #         class AntiSpam
    #           def cake
    #
    #           end
    #         end
    #       end
    #     end
    #
    # The return value of the method added should be a boolean, true for spam
    # and false for ham.
    #
    # An instance of this plugin contains the following instance variables that
    # you can use when validating a comment:
    #
    # * **engine**: the name of the anti-spam engine.
    # * **author**: the name of the person that submitted the comment.
    # * **email**: the Email address of the author.
    # * **url**: the website of the author (if any).
    # * **comment**: the actual comment.
    #
    # @author Yorick Peterse
    # @since  0.2.6
    #
    class AntiSpam
      include ::Zen::Plugin::Helper

      ##
      # Hash containing all the supported anti-spam engines and their Gems to
      # load.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      #
      Registered = {
        :defensio => 'defensio',
      }

      ##
      # Creates a new instance of the plugin and saves the passed parameters.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      # @param  [Symbol] engine The anti-spam engine to use.
      # @param  [String] author The name of the person that wrote the comment.
      # @param  [String] email The email address of the author.
      # @param  [String] url The website of the author (if any).
      # @param  [String] comment The comment.
      #
      def initialize(engine, author, email, url, comment)
        @engine, @author, @email, @url, @comment = engine, author, email, \
          url, comment

        validate_type(engine, :engine, [Symbol])

        # Load the correct gem
        if !Registered.key?(@engine) or !respond_to?(@engine)
          raise(
            ::Zen::PluginError,
            "The anti-spam engine \"#{@engine}\" is invalid"
          )
        end

        gem = Registered[@engine]

        require(gem) unless gem.nil?
      end

      ##
      # Validates the comment to see if it's spam or ham.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      # @return [TrueClass|FalseClass]
      #
      def call
        return send(@engine)
      end

      ##
      # Validates the comment using the Defensio anti-spam system.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      # @return [TrueClass|FalseClass]
      #
      def defensio
        spam    = true
        api_key = plugin(:settings, :get, :defensio_key).value

        if api_key.nil? or api_key.empty?
          raise(
            ::Zen::PluginError,
            "You need to specify an API key for the defensio system"
          )
        end

        client           = ::Defensio.new(api_key)
        status, response = client.post_document(
          :content  => @comment,
          :platform => 'zen',
          :type     => 'comment'
        )

        # Not likely to happen but just in case we'll flag the comment as spam
        return spam if status != 200

        if response['allow'] === true and response['spaminess'] <= 0.85
          spam = false
        else
          spam = true
        end

        return spam
      end
    end # AntiSpam
  end # Plugin
end # Comments
