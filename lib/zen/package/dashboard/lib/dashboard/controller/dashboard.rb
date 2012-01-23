##
# Package for the user's dashboard.
#
# ## Controllers
#
# * {Dashboard::Controller::Dashboard}
#
# ## Models
#
# * {Dashboard::Model::Widget}
#
# ## Generic Modules & Classes
#
# * {Dashboard::Widget}
# * {Dashboard::WidgetError}
#
# @since 16-01-2012
#
module Dashboard
  module Controller
    ##
    # Shows the dashboard for the currently logged in user. The dashboard shows
    # a list of user specific widgets. These widgets can be re-arranged,
    # disabled/enabled and the columns for these widgets can also be customized.
    #
    # When you open up the dashboard for the first time only one widget will be
    # displayed, the "Welcome" widget. This widget gives a very short
    # introduction to how widgets work and how to navigate around the
    # application.
    #
    # ![Default Dashboard](../../_static/dashboard/dashboard.png)
    #
    # Of course the default widget isn't very useful after the first time you've
    # read it so you might want to turn it off and enable some other widgets
    # instead. This can be done by first opening the options menu by clicking on
    # the "Options" button and then choosing which widgets you'd like to be
    # displayed.
    #
    # ![Available Widgets](../../_static/dashboard/options.png)
    #
    # This options menu also allows you to change the amount of widget columns
    # per row, as shown in the image below.
    #
    # ![Widget Columns](../../_static/dashboard/columns.png)
    #
    # @since 08-01-2012
    # @map   /admin
    #
    class Dashboard < Zen::Controller::AdminController
      map   '/admin'
      title 'dashboard.titles.%s'

      serve :css, ['admin/css/dashboard/dashboard'], :name => 'dashboard'
      serve :javascript, ['admin/js/dashboard/dashboard'], :name => 'dashboard'

      set_layout nil => [:widget_state, :widget_order, :widget_columns],
        :admin => [:index]

      ##
      # Shows all the active widgets and allows the user to manage these widgets
      # or add new ones.
      #
      # @since 08-01-2012
      #
      def index; end

      ##
      # Updates the sort order of all the widgets for the currently logged in
      # user.
      #
      # @since 15-01-2012
      #
      def widget_order
        ::Dashboard::Widget::REGISTERED.each do |name, widget|
          _name = name.to_s

          if request.POST[_name] and request.POST[_name] =~ /\d+/
            row = ::Dashboard::Model::Widget[
              :name    => _name,
              :user_id => user.id
            ]

            unless row.nil?
              row.update(:order => request.POST[_name])
            end
          end
        end
      end

      ##
      # Enables or disables a widget for the currently logged in user.
      #
      # @since 15-01-2012
      #
      def widget_state
        widget  = request.POST['widget']
        enabled = request.POST['enabled'] == '1' ? true : false

        if !widget.nil? and !widget.empty? \
        and ::Dashboard::Widget::REGISTERED.key?(widget.to_sym)
          row = ::Dashboard::Model::Widget[
            :name    => widget,
            :user_id => user.id
          ]

          if enabled == true
            if row.nil?
              last_order = ::Dashboard::Model::Widget.last_order(user.id)

              ::Dashboard::Model::Widget.create(
                :name    => widget,
                :user_id => user.id,
                :order   => last_order + 1
              )

              respond(::Dashboard::Widget[widget].html, 201)
            end
          else
            row.destroy
          end
        end
      end

      ##
      # Updates the amount of widget columns to use for the currently logged in
      # user.
      #
      # @since 15-01-2012
      #
      def widget_columns
        columns = request.POST['columns']

        if !columns.nil? and !columns.empty? and columns =~ /\d+/
          user.update(:widget_columns => columns)
        end
      end
    end # Dashboard
  end # Controller
end # Zen
