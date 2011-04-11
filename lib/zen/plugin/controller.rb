#:nodoc:
module Zen
  #:nodoc:
  module Plugin
    ##
    # Module that can be used to allows plugins to use data that would otherwise
    # only be available to controllers. Including this module gives your tags access to
    # the following methods:
    #
    # * request
    # * response
    # * session
    #
    # @author Yorick Peterse
    # @since  0.2.5
    #
    module Controller
      include ::Ramaze::Trinity
      
      ##
      # Returns the session data of the current node. This is a workaround for the
      # session() method not being available outside controllers.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @return [Object]
      # 
      def session
        return action.node.session
      end
      
      ##
      # Returns the request data of the current node. This is a workaround for the
      # request() method not being available outside controllers.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @return [Object]
      # 
      def request
        return action.node.request
      end
      
      ##
      # Returns the response data of the current node. This is a workaround for the
      # response() method not being available outside controllers.
      #
      # @author Yorick Peterse
      # @since  0.2.5
      # @return [Object]
      # 
      def response
        return action.node.response
      end

    end
  end
end

