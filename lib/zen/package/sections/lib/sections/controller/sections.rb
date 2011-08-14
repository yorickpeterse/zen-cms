#:nodoc:
module Sections
  #:nodoc:
  module Controller
    ##
    # Sections can be seen as mini applications inside your website.
    #
    # @author  Yorick Peterse
    # @since   0.1
    #
    class Sections < Zen::Controller::AdminController
      map    '/admin'
      helper :section

      javascript(['zen/lib/tabs'], :method => [:edit, :new])

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      ##
      # Constructor method, called upon initialization. It's used to set the URL
      # to which forms send their data and load the language pack.
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

        @page_title   = lang("sections.titles.#{action.method}") rescue nil
        @boolean_hash = {
          true  => lang('zen_general.special.boolean_hash.true'),
          false => lang('zen_general.special.boolean_hash.false')
        }
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

        @sections = paginate(::Sections::Model::Section)
      end

      ##
      # Hook that is executed before the edit() and new() methods.
      #
      # @author Yorick Peterse
      # @since  0.2.8
      #
      before(:edit, :new) do
        @custom_field_group_pk_hash = ::CustomFields::Model::CustomFieldGroup \
          .pk_hash(:name).invert

        @category_group_pk_hash = ::Categories::Model::CategoryGroup \
          .pk_hash(:name).invert
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
      # @param  [Fixnum] id The ID of the section to retrieve so that we can
      #  edit it.
      # @since  0.1
      #
      def edit(id)
        require_permissions(:read, :update)

        set_breadcrumbs(
          Sections.a(lang('sections.titles.index'), :index),
          @page_title
        )

        if flash[:form_data]
          @section = flash[:form_data]
        else
          @section = validate_section(id)
        end

        render_view(:form)
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

        @section = ::Sections::Model::Section.new

        render_view(:form)
      end

      ##
      # Method used for processing the form data and redirecting the user back
      # to the proper URL. Based on the value of a hidden field named "id" we'll
      # determine if the data will be used to create a new section or to update
      # an existing one.
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
          require_permissions(:update)

          @section      = validate_section(post['id'])
          save_action   = :save
        else
          require_permissions(:create)

          @section      = ::Sections::Model::Section.new
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
      # Delete an existing section. Poor section, what did he do wrong? In order
      # to delete a section you'll need to send a POST request that contains a
      # field named "section_ids[]". This field should contain the primary
      # values of each section that has to be deleted.
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
            ::Sections::Model::Section[id.to_i].destroy
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
