##
# Package for viewing and managing installed extensions such as packages and
# languages.
#
# ## Controllers
#
# * {Extensions::Controller::Extensions}
#
# This package does not provide any helpers or models.
#
# @since 18-11-2011
#
module Extensions
  module Controller
    ##
    # Controller that displays all the installed extensions.
    #
    # @since 18-11-2011
    # @map   /admin/extensions
    #
    class Extensions < Zen::Controller::AdminController
      map   '/admin/extensions'
      title 'extensions.titles.%s'

      load_asset_group :tabs

      ##
      # Shows an overview of all the installed themes, packages, added
      # languages, etc.
      #
      # @since 18-11-2011
      # @permission show_extension
      #
      def index
        authorize_user!(:show_extension)

        set_breadcrumbs(lang('extensions.titles.index'))
      end
    end # Extensions
  end # Controller
end # Extensions
