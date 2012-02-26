module Ramaze
  module Helper
    ##
    # General helper for methods that don't really belong into separate helpers.
    #
    # @since  0.3
    #
    module Controller
      ##
      # Extends the class that included this module with the ClassMethods
      # module.
      #
      # @since  0.3
      # @param  [Class] into The class that included this module.
      #
      def self.included(into)
        into.extend(Ramaze::Helper::Controller::ClassMethods)
      end

      ##
      # Returns an anchor tag that points towards the URL that allows users to
      # manage collections of data.
      #
      # @since  17-12-2011
      # @see    Ramaze::Helper::Controller#edit_link
      # @return [String]
      #
      def manage_link(url, text)
        return '<a href="%s" class="icon pages">%s</a>' % [url, text]
      end

      ##
      # Returns an anchor tag that should point to a form that allows users to
      # edit certain resources.
      #
      # @since  17-12-2011
      # @param  [#to_s] url The URL for the link.
      # @param  [#to_s] text The text to display in the link tag.
      # @return [String]
      #
      def edit_link(url, text)
        return '<a href="%s" class="icon edit">%s</a>' % [url, text]
      end

      ##
      # Returns a button that should point to a form that allows users to create
      # new resources.
      #
      # @since 17-12-2011
      # @see   Ramaze::Helper::Controller#edit_link
      #
      def new_button(url, text)
        return '<a href="%s" class="button">%s</a>' % [url, text]
      end

      ##
      # Returns a button that when clicked should delete a set of resources.
      #
      # @since  17-12-2011
      # @param  [String] text The text to display on the button.
      # @return [String]
      #
      def delete_button(text)
        return '<input type="submit" value="%s" class="button danger" />' \
          % text
      end

      ##
      # Checks if a given object can be paginated and the page count is greater
      # than 1. If this is the case then the pagination links are displayed.
      #
      # @since  17-12-2011
      # @param  [Mixed] object
      # @return [String]
      #
      def render_pagination(object)
        if object.respond_to?(:navigation) and object.page_count > 1
          return object.navigation
        end
      end

      ##
      # Returns a string containing the name of the browser. The following
      # values can be returned:
      #
      # * firefox
      # * internet_explorer
      # * chrome
      # * safari
      # * other
      #
      # Note that this method does a very simple check and thus should not be
      # relied on for anything mission critical.
      #
      # @since  23-12-2011
      # @param  [String] agent String containing the user agent to check, set to
      #  ``request.env['HTTP_USER_AGENT']`` if no custom agent is specified.
      # @return [String]
      #
      def browser_name(agent = nil)
        agent ||= request.env['HTTP_USER_AGENT']

        if agent.nil? or agent.empty?
          return 'other'
        end

        case agent.downcase
        when /chrome/
          return 'chrome'

        when /safari/
          return 'safari'

        when /msie/
          return 'internet_explorer'

        when /firefox/
          return 'firefox'
        end

        return 'other'
      end

      ##
      # Writes a JSON response.
      #
      # @since 13-02-2012
      # @param [Mixed] data The response data.
      # @param [Fixnum] status The HTTP status code.
      #
      def respond_json(data, status = 200)
        respond(JSON.dump(data), status, 'Content-Type' => 'application/json')
      end

      ##
      # Returns a hash containing all the given POST fields, similar to
      # ``Innate::Request#subset``.
      #
      # @since  19-02-2012
      # @param  [Array] *keys The POST keys to retrieve.
      # @return [Hash]
      #
      def post_fields(*keys)
        keys = keys.map { |k| k.to_s }

        request.POST.reject { |k, v| not keys.include?(k) }
      end

      ##
      # Returns a JSON string containing all the translations for the Javascript
      # code.
      #
      # @since  19-02-2012
      # @return [String]
      #
      def javascript_translations
        hash = {}

        Zen::JAVASCRIPT_TRANSLATIONS.each do |key|
          hash[key] = lang(key)
        end

        return JSON.dump(hash)
      end

      ##
      # Methods that become available as class methods.
      #
      # @since  0.3
      #
      module ClassMethods
        ##
        # Sets the title for all the methods based on a language string. If
        # there's no corresponding language key the title will not be set.
        #
        # @example
        #  class Foo < Zen::Controller::AdminController
        #    title 'foo.titles.%s'
        #  end
        #
        # @since  0.3
        # @param  [String] title The language key to use, a %s will be replaced
        #  with the name of the current action.
        #
        def title(title)
          stacked_before_all(:set_page_title) do
            @page_title = lang(title % action.method) rescue nil
          end
        end

        ##
        # Protects the specified methods against CSRF attacks. If a CSRF token
        # is missing the user will see the message defined in the language key
        # "zen_general.errors.csrf" and the HTTP status code will be set to 403.
        #
        # @example
        #  class Foo < Zen::Controller::AdminController
        #    csrf_protection :save, :delete
        #  end
        #
        # @since  0.3
        # @param  [Array] *actions An array of action names to protect against
        #  CSRF attacks.
        #
        def csrf_protection(*actions)
          stacked_before_all(:validate_csrf_token) do
            csrf_protection(*actions) do
              message(:error, lang('zen_general.errors.csrf'))

              unless request.POST.empty?
                request.POST.delete('id')
                request.POST.delete('csrf_token')

                flash[:form_data] = request.POST
              end

              redirect_referrer(::Dashboard::Controller::Dashboard.r(:index))
            end
          end
        end

        ##
        # Creates a method that can be used for automatically saving an existing
        # object. This method requires you to supply the following:
        #
        # * A model that extends ``Sequel::Model``
        # * An array of columns that can be specified
        #
        # @example
        #  autosave Model::CategoryGroup,
        #  [:name, :description],
        #  :edit_category_group
        #
        # @since 13-02-2012
        # @param [Class] model The model to use for saving data.
        # @param [Array] columns The columns that can be saved.
        # @param [#to_sym] permission The permission required for saving
        #  objects.
        #
        def autosave(model, columns, permission)
          self.instance_eval do
            define_method :autosave do
              csrf_protection(:autosave) do
                respond(lang('zen_general.errors.csrf'), 403)
              end

              post   = post_fields(*columns)
              object = model[request.params['id']]

              if object.nil? or !user_authorized?(permission)
                respond_json(
                  {:error => lang('zen_general.errors.invalid_request')},
                  404
                )
              else
                begin
                  post.each do |k, v|
                    object.send("#{k}=", v) if object.respond_to?("#{k}=")
                  end

                  object.save

                  respond_json({:csrf_token => get_csrf_token}, 200)
                rescue => e
                  Ramaze::Log.error(e)

                  respond_json({:errors  => object.errors}, 400)
                end
              end
            end
          end
        end
      end # ClassMethods
    end # Controller
  end # Helper
end # Ramaze
