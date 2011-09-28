#:nodoc:
module Categories
  #:nodoc:
  module Controller
    ##
    # Controller used for managing category groups. Individual categories are
    # managed by the Categories controller.
    #
    # ## Used Permissions
    #
    # * show_category_group
    # * edit_category_group
    # * new_category_group
    # * delete_category_group
    #
    # ## Available Events
    #
    # * new_category_group
    # * edit_category_group
    # * delete_category_group
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class CategoryGroups < Zen::Controller::AdminController
      helper :category
      map    '/admin/category-groups'
      title  'category_groups.titles.%s'

      # Protects CategoryGroups#save() and CategoryGroups#delete() against CSRF
      # attacks.
      csrf_protection :save, :delete

      ##
      # Show an overview of all existing category groups and allow the user
      # to create new category groups or manage individual categories.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        authorize_user!(:show_category_group)

        set_breadcrumbs(lang('category_groups.titles.index'))

        @category_groups = paginate(::Categories::Model::CategoryGroup)
      end

      ##
      # Allows a user to edit an existing category group.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [Fixnum] id The ID of the category group to edit.
      #
      def edit(id)
        authorize_user!(:edit_category_group)

        set_breadcrumbs(
          CategoryGroups.a(lang('category_groups.titles.index'), :index),
          lang('category_groups.titles.edit')
        )

        @category_group = flash[:form_data] || validate_category_group(id)

        render_view(:form)
      end

      ##
      # Allows the user to add a new category group.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        authorize_user!(:new_category_group)

        set_breadcrumbs(
          CategoryGroups.a(lang('category_groups.titles.index'), :index),
          lang('category_groups.titles.new')
        )

        @category_group = ::Categories::Model::CategoryGroup.new

        render_view(:form)
      end

      ##
      # Creates a new category or updates the data of an existing category. If a
      # category ID is specified (in the POST key "id") that existing category
      # will be updated, otherwise a new one will be created.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        post = request.subset(:id, :name, :description)

        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_category_group)

          category_group = validate_category_group(post['id'])
          save_action    = :save
          event          = :new_category_group
        else
          authorize_user!(:new_category_group)

          category_group = ::Categories::Model::CategoryGroup.new
          save_action    = :new
          event          = :edit_category_group
        end

        success = lang("category_groups.success.#{save_action}")
        error   = lang("category_groups.errors.#{save_action}")

        post.delete('id')

        begin
          category_group.update(post)
        rescue => e
          message(:error, error)
          Ramaze::Log.error(e.inspect)

          flash[:form_data]   = category_group
          flash[:form_errors] = category_group.errors

          redirect_referrer
        end

        Zen::Event.call(event, category_group)

        message(:success, success)
        redirect(CategoryGroups.r(:edit, category_group.id))
      end

      ##
      # Deletes a number of category groups. The IDs of these groups should be
      # specified in the POST array "category_group_ids".
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        authorize_user!(:delete_category_group)

        post = request.subset(:category_group_ids)

        if post['category_group_ids'].nil? or post['category_group_ids'].empty?
          message(:error, lang('category_groups.errors.no_delete'))
          redirect(CategoryGroups.r(:index))
        end

        post['category_group_ids'].each do |id|
          group = ::Categories::Model::CategoryGroup[id]

          next if group.nil?

          begin
            group.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('category_groups.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_category_group, group)
        end

        message(:success, lang('category_groups.success.delete'))
        redirect_referrer
      end
    end # CategoryGroups
  end # Controller
end # Categories
