#:nodoc:
module Ramaze
  #:nodoc:
  module Helper
    ##
    # Helper that contains several common methods for which creating their
    # own helper would be a bit of an overkill.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    module Common
      ##
      # Generate the required data for showing a Javascript based notification.
      # Basically all this method does is storing a hash in the flash data and
      # making the required code to do so slightly shorter.
      #
      # @author Yorick Peterse
      # @param  [Symbol] type The type of notification to generate (error, notice, etc).
      # @param  [String] title The title of the notification.
      # @param  [String] message The message to display in the notification.
      # @param  [String] image An optional path to a custom image to use. If no image 
      # is specified the type of notification will be used for the image. For example, 
      # an error message would result in an image named "error.png" (.png is used for 
      # all default icons).
      # @param  [Boolean] sticky Boolean that indicates that the notification shouldn't
      # be automatically removed after a certain period of time.
      # @since  0.1
      #
      def notification(type, title, message, image = nil, sticky = false)
        if image.nil?
          image = "/admin/images/icons/large/#{type.to_s}.png"
        end
        
        sticky = true if type === :error
        
        flash[:notification] = {
          :title   => title,
          :content => message,
          :image   => image,
          :sticky  => sticky
        }
      end
      
      ##
      # Generate an anchor tag inspired by the way Rails does this. 
      # The first parameter is the text to display, the second parameter is the URL.
      #
      # The anchor_to tag supports both query string parameters just like the link helper
      # that ships with Ramaze but it also supports the possibility of adding HTML
      # attributes such as an ID or class. 
      # 
      # URLs can be formatted in two ways. The first one, which is the most common one,
      # is using a path to a controller/method. Simply specify a string such as
      # "controller/method". If you want to create an anchor that points to an external
      # website, say Google, simply start the string with "http://" and you're good to go.
      #
      # @example
      #  # Rather verbose isn't it?
      #  anchor_to(
      #    'Google Search', 
      #    {:href => 'http://google.com', :q => 'Search term' }, 
      #    :class => 'anchor_class', 
      #    :title => 'Google Search Results :D'
      #  )
      #
      #  # This is also perfectly fine
      #  anchor_to('Dashboard', 'dashboard')
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [String] text The text to display in the anchor tag.
      # @param  [Hash/String] url Either a hash or a string that defines the URL.
      # When using a hash the :href key will be used for the link location.
      # Other keys will be used to create query string items. If the URL starts with
      # http:// it will be an external URL.
      # @param  [Array] attributes Optional HTML attributes to add to the anchor tag.
      # @return [String]
      #
      def anchor_to(text, url, *attributes)
        
        # Sanitize the text and URL
        text = Rack::Utils.escape_html(text)
        url  = url.to_s

        # Get the URL from the second parameter (either a string or a hash).
        if url.class === Hash
          # Get the URL from the hash and delete it
          anchor_url   = url[:href].strip          
          url.delete(anchor_url)
          
          # Generate the query string based on the left over values in the URL hash
          query_string = Rack::Utils.build_query(url)
          
          # Create the full URL
          anchor_url = anchor_url + query_string 
         else
          anchor_url = url
        end

        # Got attributes?
        if !attributes or attributes.empty?
          attributes = {}
        else
          attributes = attributes[0]
        end

        # Check to see if we're dealing with an internal or external URL
        if !anchor_url.include? '://' or !anchor_url.include? 'www.'
          if anchor_url[0] == '/'
            prefix = ''
          else
            prefix = '/'
          end

          anchor_url = request.domain("#{prefix}#{anchor_url}")
        end
        
        # Add the href attribute so it gets processed
        attributes['href'] = anchor_url
        
        # Add all the extra arguments
        html_attributes = String.new
        
        attributes.each do |attribute, value|
          attribute         = Rack::Utils.escape_html attribute
          html_attributes  += "#{attribute}=\"#{value}\" "
        end
        
        # Remove the trailing space
        html_attributes = html_attributes.strip
        
        # Return the tag
        return "<a #{html_attributes}>#{text}</a>"
      end
      
      ##
      # The cycle method cycles through a specified list of words. This helper can be
      # used to generate "zebra" tables, meaning that every odd row has a different color.
      #
      # The amount of words you want to cycle through is completely customizable,
      # however you should atleast have two words otherwise this method will be
      # completely useless.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [Array] args All words to cycle through.
      # @return [String]
      #
      def cycle(*args)
        @@cycle_counter ||= 0
        
        # Check the current counter and reset it if it matches the total amount of arguments
        if @@cycle_counter >= args.count
          # Reset the counter
          @@cycle_counter = 0
        end
        
        # Get the element based on the current index
        cycle_element = args[@@cycle_counter]
        
        # Increment the counter
        @@cycle_counter += 1
        
        # Return the cycle element
        return cycle_element
      end
    end
  end
end
