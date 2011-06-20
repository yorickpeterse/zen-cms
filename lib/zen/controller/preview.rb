#:nodoc
module Zen
  #:nodoc
  module Controller
    ##
    # Controller that can be used to render a block of markup based on the POST 
    # data. This controller is useful for generating previews when using the 
    # text editor for example.
    #
    # In order to render a preview you'll have to send a POST request with the 
    # following data in it:
    #
    # * engine: The markup engine to use (Markdown, Textile, etc).
    # * markup: The markup to convert to HTML.
    #
    # An example of such a request would look like the following:
    #
    #     POST /admin/preview
    #     engine: "markdown"
    #     markup: "Hello **world**!"
    #
    # The return data is an HTTP status code and the HTML as the body. The HTTP 
    # status code will be 200 whenever the data was converted and or 400 in case 
    # of an error (e.g. an incorrect markup engine was specified).
    #
    # @author Yorick Peterse
    # @since  0.2.6
    #
    class Preview < Zen::Controller::AdminController
      map '/admin/preview'

      ##
      # Converts the markup set in the POST data and returns the HTML.
      #
      # @author Yorick Peterse
      # @since  0.2.6
      #
      def index
        if !request.params['engine'] or !request.params['markup']
          respond(lang('zen_general.errors.invalid_request'), 400)
        end

        begin
          respond(
            plugin(:markup, request.params['engine'], request.params['markup']), 
            200
          )
        rescue
          respond(lang('zen_general.errors.invalid_request'), 400)
        end
      end
    end # Preview
  end # Controller
end # Zen
