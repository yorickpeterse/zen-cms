module Comments
  ##
  # {Comments::AntiSpam} is a module that can be used to verify if a comment is
  # spam or ham. In order to validate a comment you'll have to call
  # {Comments::AntiSpam.validate} and pass a set of parameters to it (see the
  # documentation of {Comments::AntiSpam.validate} for more information). An
  # example of validating a comment using Defensio looks like the following:
  #
  #     spam = Comments::AntiSpam.validate(
  #       :defensio,
  #       nil,
  #       nil,
  #       nil,
  #       'This is a comment that has to be validated'
  #     )
  #
  # ## Supported Systems
  #
  # By default only Defensio is supported.
  #
  # ## Adding Systems
  #
  # Adding a new anti spam system is done in two steps. First you must add the
  # name of the method to {Comments::AntiSpam::REGISTERED} (the method should be
  # a symbol). This constant is a hash of which the keys are the method names of
  # the engines to invoke and the values the labels to display in the admin
  # panel. Without this the {Comments::AntiSpam.validate} method will raise an
  # error. This check is put in place to ensure that the user can't potentially
  # exploit the system.
  #
  # Once the method has been added to the list you must actually implement it as
  # a class method. The syntax of such a method looks like the following:
  #
  #     def self.method_name(author, email, url, comment)
  #
  #     end
  #
  # The return value should be a boolean that indicates whether or not the
  # comment is spam. A return value of ``true`` indicates that the comment is
  # spam, anything that evaluates to ``false`` indicates that the comment is
  # valid.
  #
  # In order to add your method you simply add it like you normally would with
  # any other class:
  #
  #     module Comments
  #       module AntiSpam
  #         private
  #
  #         def self.custom_method(author, email, url, comment)
  #
  #         end
  #       end
  #     end
  #
  #
  # @since  0.3
  #
  module AntiSpam
    # Array containing the method names of the various supported engines and
    # their labels to display in the admin interface.
    REGISTERED = {
      :defensio => lang('comments.labels.defensio')
    }

    class << self
      ##
      # Validates a comment to see if it's spam or ham using a given engine.
      # Defensio only validates the comment itself.
      #
      # @example
      #  Comments::AntiSpam.validate(
      #    :defensio,
      #    'Chuch Norris',
      #    'chuck@chucknorris.com',
      #    'http://chucknorris.com/',
      #    '.....'
      #  )
      #
      # @since  0.3
      # @param  [#to_sym] engine The name of the anti spam engine to use.
      # @param  [String] author The name of the author of the comment.
      # @param  [String] email The Email address of the author.
      # @param  [String] url The URL that points to the user's website
      #  (optional).
      # @param  [String] comment The comment to validate.
      # @return [TrueClass|FalseClass]
      #
      def validate(engine, author, email, url, comment)
        engine = engine.to_sym

        unless REGISTERED.key?(engine)
          raise(ArgumentError, "The engine \"#{engine}\" is invalid")
        end

        return send(engine, author, email, url, comment)
      end

      ##
      # Validates a comment using Defensio.
      #
      # @since  0.3
      # @see    Comments::AntiSpam.validate
      #
      def defensio(author, email, url, comment)
        if !Kernel.const_defined?(:Defensio)
          Ramaze.setup(:verbose => false) do
            gem 'defensio'
          end
        end

        spam    = true
        api_key = get_setting(:defensio_key).value

        if api_key.nil? or api_key.empty?
          raise('You need to specify an API key for the defensio system')
        end

        client           = Defensio.new(api_key)
        status, response = client.post_document(
          :content  => comment,
          :platform => 'zen',
          :type     => 'comment'
        )

        return spam if status != 200

        if response['allow'] == true and response['spaminess'] <= 0.85
          spam = false
        else
          spam = true
        end

        return spam
      end
    end # class << self
  end # AntiSpam
end # Comments
