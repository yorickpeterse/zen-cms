module Dashboard
  # Error class for the widgets system.
  class WidgetError < StandardError; end

  ##
  #
  # @since 08-01-2012
  #
  class Widget
    include Zen::Validation

    # Hash containing all the registered widgets.
    REGISTERED = {}

    # Array containing the amount of widget columns.
    COLUMNS = [1, 2, 3, 4]

    # The name of the widget as a symbol.
    attr_reader :name

    # The title of the widget (displayed on the dashboard).
    attr_writer :title

    # An object that responds to #call() and returns the content of the widget.
    # When called the first parameter is set to ``Ramaze::Current.action``
    # allowing you to use methods such as ``render_view``.
    attr_accessor :data

    class << self
      ##
      # Adds a new widget. Widgets are defined as following:
      #
      #     Dashboard::Widget.add do |w|
      #       w.name  = :recent_entries
      #       w.title = 'Recent Entries'
      #       w.data  = lambda do |action|
      #         return action.node.render_view(:example)
      #       end
      #     end
      #
      # @since 08-01-2012
      #
      def add
        widget = self.new

        yield(widget)
        widget.validate

        REGISTERED[widget.name] = widget
      end

      ##
      # Retrieves the widget for the given name.
      #
      # @example
      #  Dashboard::Widget[:recent_entries]
      #
      # @since 08-01-2012
      #
      def [](name)
        name = name.to_sym

        unless REGISTERED.key?(name)
          raise(WidgetError, "The widget \"#{name}\" does not exist")
        end

        return REGISTERED[name]
      end

      ##
      # Generates the HTML for all active widgets and sorts them by the user's
      # sort order.
      #
      # @since  14-01-2012
      # @return [String]
      #
      def html
        html    = ''
        widgets = Dashboard::Model::Widget.select(:name) \
          .filter(:user_id => user.id) \
          .order(:order.asc)

        widgets.each do |row|
          html += Widget[row.name].html
        end

        return html
      end

      ##
      # Builds the HTML for the radio buttons that can be used to change the
      # amount of widget columns.
      #
      # @since  15-01-2012
      # @return [String]
      #
      def columns_html
        g       = Ramaze::Gestalt.new
        current = user.widget_columns

        COLUMNS.each do |c|
          params = {:name => 'widget_columns', :type => 'radio', :value => c}

          params[:checked] = 'checked' if c == current

          g.span(:class => 'radio_wrap') do
            g.input(params)

            g.out << c
          end
        end

        return g.to_s
      end

      ##
      # Generates a chunk of HTML that contains various checkboxes to toggle the
      # state of all widgets.
      #
      # @since  14-01-2012
      # @return [String]
      #
      def checkbox_html
        g      = Ramaze::Gestalt.new
        active = Dashboard::Model::Widget.select(:name) \
          .filter(:user_id => user.id) \
          .map { |r| r.name.to_sym }

        REGISTERED.each do |name, widget|
          params = {
            :type  => 'checkbox',
            :name  => 'active_widgets[]',
            :value => 'widget_' + name.to_s
          }

          params[:checked] = 'checked' if active.include?(name)

          g.span(:class => 'checkbox_wrap') do
            g.input(params)

            g.out << widget.title
          end
        end

        return g.to_s
      end

      private

      ##
      # Returns the current user model.
      #
      # @since  15-01-2012
      # @return [Users::Model::User]
      def user
        return Ramaze::Current.action.node.request.env[
          Ramaze::Helper::UserHelper::RAMAZE_HELPER_USER
        ]
      end
    end # class << self

    ##
    # Sets the name of the widget and converts it to a symbol.
    #
    # @since 11-01-2012
    # @param [#to_sym] name The name of the widget.
    #
    def name=(name)
      @name = name.to_sym
    end

    ##
    # Returns the title of the widget. If the title is set to a valid language
    # string the value of that string is returned, otherwise the raw title is
    # returned.
    #
    # @since  11-01-2012
    # @return [String]
    #
    def title
      begin
        return lang(@title)
      rescue
        return @title
      end
    end

    ##
    # Validates the instance of the widget.
    #
    # @since 11-01-2012
    #
    def validate
      validates_presence([:name, :title, :data])

      if REGISTERED.key?(name)
        raise(WidgetError, "The widget \"#{name}\" already exists")
      end
    end

    ##
    # Returns a string containing the full HTML for the widget. The HTML of each
    # widget looks like the following:
    #
    #     <section class="widget" id="widget_example">
    #         <header>
    #             <h1>Example</h1>
    #         </header>
    #
    #         <div class="body">
    #             Widget content
    #         </div>
    #     </section>
    #
    # @since  12-01-2012
    # @return [String]
    #
    def html
      g       = Ramaze::Gestalt.new
      _action = Ramaze::Current.action

      g.section(:class => 'widget', :id => 'widget_' + name.to_s) do
        g.header do
          g.h1(title)
        end

        g.div(:class => 'body') do
          data.call(_action)
        end
      end

      return g.to_s
    end
  end # Widget
end # Dashboard
