#:nodoc:
module Sections
  #:nodoc:
  module Controller
    ##
    # Sections can be seen as mini applications inside your website.
    # Examples of sections can be a blog, pages, a products listing, etc.
    # Before being able to properly add section entries you need to assign
    # the following data to a section:
    #
    # * a category group
    # * a custom field group
    #
    # @author  Yorick Peterse
    # @since   0.1
    #
    class Sections < Zen::Controller::AdminController
      include ::Sections::Model

      map '/admin'
      helper :section

      # Load all required Javascript files
      javascript ['zen/tabs']

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      ##
      # Constructor method, called upon initialization. It's used to set the
      # URL to which forms send their data and load the language pack.
      #
      # This method loads the following language files:
      #
      # * sections
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super

        @form_save_url   = Sections.r(:save)
        @form_delete_url = Sections.r(:delete)

        Zen::Language.load('sections')

        # Set the page title
        if !action.method.nil?
          method      = action.method.to_sym
          @page_title = lang("sections.titles.#{method}") rescue nil
        end
      end

      ##
      # Show an overview of all existing sections. Using this overview a user
      # can manage an existing section, delete it or create a new one.
      #
      # This method requires the following permissions:
      #
      # * read
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        require_permissions(:read)

        set_breadcrumbs(lang('sections.titles.index'))

        @sections = Section.all
      end

      ##
      # Show a form that lets the user edit an existing section.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @param  [Integer] id The ID of the section to retrieve so that we can 
      # edit it.
      # @since  0.1
      #
      def edit(id)
        require_permissions(:read, :update)

        set_breadcrumbs(
          Sections.a(lang('sections.titles.index'), :index),
          @page_title
        )

        @custom_field_group_pk_hash = CustomFields::Model::CustomFieldGroup \
          .pk_hash(:name)

        @category_group_pk_hash = Categories::Model::CategoryGroup \
          .pk_hash(:name)

        if flash[:form_data]
          @section = flash[:form_data]
        else
          @section = validate_section(id)
        end
      end

      ##
      # Show a form that lets the user create a new section.
      #
      # This method requires the following permissions:
      #
      # * create
      # * read
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        require_permissions(:create, :read)

        set_breadcrumbs(
          Sections.a(lang('sections.titles.index'), :index),
          @page_title
        )

        @custom_field_group_pk_hash = CustomFields::Model::CustomFieldGroup \
          .pk_hash(:name)

        @category_group_pk_hash = Categories::Model::CategoryGroup \
          .pk_hash(:name)

        @section = Section.new
      end

      ##
      # Method used for processing the form data and redirecting the user back 
      # to the proper URL. Based on the value of a hidden field named "id" 
      # we'll determine if the data will be used to create a new section or to 
      # update an existing one.
      #
      # This method requires the following permissions:
      #
      # * create
      # * update
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        require_permissions(:create, :update)

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
          @section      = validate_section(post['id'])
          save_action   = :save
        else
          @section      = Section.new
          save_action   = :new
        end

        flash_success = lang("sections.success.#{save_action}")
        flash_error   = lang("sections.errors.#{save_action}")

        post['custom_field_group_pks'] ||= []
        post['category_group_pks']     ||= []

        # The primary keys have to be integers otherwise Sequel will soil it's 
        # pants
        ['custom_field_group_pks', 'category_group_pks'].each do |k|
          post[k].map! { |value| value.to_i }
        end

        # Auto generate the slug if it's empty
        post.delete('slug') if post['slug'].empty?
        post.delete('id')

        begin
          @section.update(post)

          if save_action == :new
            @section.custom_field_group_pks = post['custom_field_group_pks']
            @section.category_group_pks     = post['category_group_pks']
          end

          message(:success, flash_success)
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, flash_error)

          flash[:form_data]   = @section
          flash[:form_errors] = @section.errors

          redirect_referrer
        end

        if @section.id
          redirect(Sections.r(:edit, @section.id))
        else
          redirect_referrer
        end
      end

      ##
      # Delete an existing section. Poor section, what did he do wrong?
      # In order to delete a section you'll need to send a POST request that 
      # contains a field named "section_ids[]". This field should contain the 
      # primary values of each section that has to be deleted.
      #
      # This method requires the following permissions:
      #
      # * delete
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        require_permissions(:delete)

        if !request.params['section_ids'] or request.params['section_ids'].empty?
          message(:error, lang('sections.errors.no_delete'))
          redirect_referrer
        end

        request.params['section_ids'].each do |id|
          begin
            Section[id.to_i].destroy
            message(:success, lang('sections.success.delete'))
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('sections.errors.delete') % id)

            redirect_referrer
          end
        end

        redirect_referrer
      end
    end # Sections
  end # Controller
end # Sections
