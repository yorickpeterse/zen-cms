#:nodoc:
module Sections
  #:nodoc:
  module Controller
    ##
    # Sections can be seen as mini applications inside your website.
    #
    # ## Used Permissions
    #
    # * show_section
    # * new_section
    # * edit_section
    # * delete_section
    #
    # ## Available Events
    #
    # * new_section
    # * edit_section
    # * delete_section
    #
    # @author  Yorick Peterse
    # @since   0.1
    #
    class Sections < Zen::Controller::AdminController
      map    '/admin'
      helper :section
      title  'sections.titles.%s'

      csrf_protection  :save, :delete
      load_asset_group :tabs, [:edit, :new]

      # Hook that is executed before Sections#index(), Sections#new() and
      # Sections#edit().
      before(:index, :new, :edit) do
        @boolean_hash = {
          true  => lang('zen_general.special.boolean_hash.true'),
          false => lang('zen_general.special.boolean_hash.false')
        }

        @custom_field_group_pk_hash = ::CustomFields::Model::CustomFieldGroup \
          .pk_hash(:name).invert

        @category_group_pk_hash = ::Categories::Model::CategoryGroup \
          .pk_hash(:name).invert
      end

      ##
      # Show an overview of all existing sections. Using this overview a user
      # can manage an existing section, delete it or create a new one.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        authorize_user!(:show_section)

        set_breadcrumbs(lang('sections.titles.index'))

        @sections = paginate(::Sections::Model::Section)
      end

      ##
      # Show a form that lets the user edit an existing section.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] id The ID of the section to edit.
      # @since  0.1
      #
      def edit(id)
        authorize_user!(:edit_section)

        set_breadcrumbs(
          Sections.a(lang('sections.titles.index'), :index),
          @page_title
        )

        @section = flash[:form_data] || validate_section(id)

        render_view(:form)
      end

      ##
      # Show a form that lets the user create a new section.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        authorize_user!(:new_section)

        set_breadcrumbs(
          Sections.a(lang('sections.titles.index'), :index),
          @page_title
        )

        @section = flash[:form_data] || ::Sections::Model::Section.new

        render_view(:form)
      end

      ##
      # Method used for processing the form data and redirecting the user back
      # to the proper URL. Based on the value of a hidden field named "id" we'll
      # determine if the data will be used to create a new section or to update
      # an existing one.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        post = request.subset(
          :id,
          :name,
          :slug,
          :description,
          :comment_allow,
          :comment_require_account,
          :comment_moderate,
          :comment_format,
          :custom_field_group_pks,
          :category_group_pks
        )

        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_section)

          section     = validate_section(post['id'])
          save_action = :save
          event       = :edit_section
        else
          authorize_user!(:new_section)

          section     = ::Sections::Model::Section.new
          save_action = :new
          event       = :new_section
        end

        success = lang("sections.success.#{save_action}")
        error   = lang("sections.errors.#{save_action}")

        post['custom_field_group_pks'] ||= []
        post['category_group_pks']     ||= []

        # The primary keys have to be integers otherwise Sequel will soil it's
        # pants
        ['custom_field_group_pks', 'category_group_pks'].each do |k|
          post[k].map! { |value| value.to_i }
        end

        post.delete('id')

        begin
          section.update(post)

          if save_action == :new
            section.custom_field_group_pks = post['custom_field_group_pks']
            section.category_group_pks     = post['category_group_pks']
          end
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, error)

          flash[:form_data]   = section
          flash[:form_errors] = section.errors

          redirect_referrer
        end

        Zen::Event.call(event, section)

        message(:success, success)
        redirect(Sections.r(:edit, section.id))
      end

      ##
      # Delete an existing section. Poor section, what did he do wrong? In order
      # to delete a section you'll need to send a POST request that contains a
      # field named "section_ids[]". This field should contain the primary
      # values of each section that has to be deleted.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        authorize_user!(:delete_section)

        if !request.params['section_ids'] or request.params['section_ids'].empty?
          message(:error, lang('sections.errors.no_delete'))
          redirect_referrer
        end

        request.params['section_ids'].each do |id|
          section = ::Sections::Model::Section[id]

          next if section.nil?

          begin
            section.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('sections.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_section, section)
        end

        message(:success, lang('sections.success.delete'))
        redirect_referrer
      end
    end # Sections
  end # Controller
end # Sections
