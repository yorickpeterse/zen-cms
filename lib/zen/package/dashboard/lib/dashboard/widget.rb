module Dashboard
  # Error class for the widgets system.
  class WidgetError < StandardError; end

  ##
  # Widgets are small blocks of content displayed on a user's dashboard. These
  # widgets can contain data such as recent entries, a help message or a graph
  # showing the website's traffic.
  #
  # In order to create a new widget you should call {Dashboard::Widget.add} and
  # pass a block to it. In this block you can set the following attributes:
  #
  # * name: the unique name of the widget.
  # * title: the title of the widget, can either be a language string or a
  #   regular one.
  # * data: an object that responds to ``#call()`` and returns the content of
  #   the widget. This object is evaluated in the context of the current
  #   controller instance ({Dashboard::Controller::Dashboard}). If you're using
  #   a lambda you *have to* specify a first parameter as ``#instance_eval``
  #   will always pass the evaluated instance as a parameter. If you don't want
  #   to do this you can use ``Proc.new { }`` or simply ``proc { }`` as an
  #   alternative.
  #
  # An example of adding a widget is the following:
  #
  #     Dashboard::Widget.add do |w|
  #       w.name  = :example_widget
  #       w.title = 'dashboard.titles.example_widget'
  #       w.data  = lambda do |instance|
  #         return render_view(:example_view)
  #       end
  #     end
  #
  # Once a widget has been registered it can be retrieved using
  # {Dashboard::Widget#[]}:
  #
  #     Dashboard::Widget[:example_widget] # => <Dashboard::Widget ...>
  #
  # @since 2012-01-08
  #
  class Widget
    include Zen::Validation
    include Ramaze::Trinity
    include Ramaze::Helper::ACL

    # Hash containing all the registered widgets.
    REGISTERED = {}

    # Array containing the amount of widget columns.
    COLUMNS = [1, 2, 3, 4]

    # The name of the widget as a symbol.
    attr_reader :name

    # The title of the widget (displayed on the dashboard).
    attr_writer :title

    # A permission required to view a widget.
    attr_accessor :permission

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
      # @since 2012-01-08
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
      # @since 2012-01-08
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
      # @since  2012-01-14
      # @return [String]
      #
      def html
        html    = ''
        widgets = Dashboard::Model::Widget.select(:name) \
          .filter(:user_id => user.id) \
          .order(:order.asc)

        widgets.each do |row|
          name  = row.name
          html += Widget[name].html if Widget[name].allowed?
        end

        return html
      end

      ##
      # Builds the HTML for the radio buttons that can be used to change the
      # amount of widget columns.
      #
      # @since  2012-01-15
      # @return [String]
      #
      def columns_html
        g       = Ramaze::Gestalt.new
        current = user.widget_columns

        COLUMNS.each do |c|
          params = {
            :name  => 'widget_columns',
            :type  => 'radio',
            :value => c,
            :id    => 'widget_columns_%s' % c
          }

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
      # @since  2012-01-14
      # @return [String]
      #
      def checkbox_html
        g      = Ramaze::Gestalt.new
        active = Dashboard::Model::Widget.select(:name) \
          .filter(:user_id => user.id) \
          .map { |r| r.name.to_sym }

        REGISTERED.each do |name, widget|
          next unless widget.allowed?

          params = {
            :type  => 'checkbox',
            :name  => 'active_widgets[]',
            :value => 'widget_%s' % name,
            :id    => 'toggle_widget_%s' % name
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
      # @since  2012-01-15
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
    # @since 2012-01-11
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
    # @since  2012-01-11
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
    # Checks if the user is allowed to view the current widget.
    #
    # @since  2012-01-16
    # @return [TrueClass|Falseclass]
    #
    def allowed?
      return true if @permission.nil?
      return user_authorized?(@permission)
    end

    ##
    # Validates the instance of the widget.
    #
    # @since 2012-01-11
    #
    def validate
      validates_presence([:name, :title, :data])

      if REGISTERED.key?(name)
        raise(Zen::ValidationError, "The widget \"#{name}\" already exists")
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
    # @since  2012-01-12
    # @return [String]
    #
    def html
      g      = Ramaze::Gestalt.new
      action = Ramaze::Current.action

      g.section(:class => 'widget', :id => 'widget_' + name.to_s) do
        g.header do
          g.h1(title)
        end

        g.div(:class => 'body') do
          action.instance.instance_eval(&data)
        end
      end

      return g.to_s
    end
  end # Widget
end # Dashboard
