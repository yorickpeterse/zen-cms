module Ramaze
  #:nodoc:
  module Helper
    ##
    # Helper for the Categories package. Note that this helper requires the
    # helper Ramaze::Helper::Message to be loaded.
    #
    # @since   0.2.8
    #
    module Category
      ##
      # Checks if the specified category group ID results in a valid instance of
      # Categories::Model::CategoryGroup. If this is the case the object is
      # returned, otherwise the user is redirected back to the overview of all
      # category groups and is informed about the group being invalid.
      #
      # @since  0.2.8
      # @param  [Fixnum] category_group_id The ID of the category group to
      #  validate.
      # @return [Categories::Model::CategoryGroup]
      #
      def validate_category_group(category_group_id)
        unless category_group_id =~ /\d+/
          redirect_invalid_group
        end

        group = ::Categories::Model::CategoryGroup[category_group_id]

        if group.nil?
          redirect_invalid_group
        else
          return group
        end
      end

      ##
      # Similar to validate_category_group this method checks if a category is
      # valid or not. If it's valid the object is returned, otherwise an error
      # is displayed and the user is redirected back to the overview of
      # categories.
      #
      # @since  0.2.8
      # @param  [Fixnum] category_id The ID of the category.
      # @param  [Fixnum] category_group_id The ID of the category group, used
      #  when redirecting the user.
      # @return [Categories::Model::Category]
      #
      def validate_category(category_id, category_group_id)
        unless category_id =~ /\d+/
          redirect_invalid_category(category_group_id)
        end

        category = ::Categories::Model::Category[category_id]

        if category.nil?
          redirect_invalid_category(category_group_id)
        else
          return category
        end
      end

      ##
      # Method that extracts all the possible parent categories for a given
      # category group ID.
      #
      # @since  0.2.8
      # @param  [Fixnum[ category_id The ID of the category, this one will be
      #  excluded from the hash.
      # @param  [Fixnum] category_group_id The ID of a category group for which
      #  to retrieve all the possible parent items.
      # @return [Hash]
      #
      def parent_categories(category_id, category_group_id)
        parent_categories = {}

        Categories::Model::CategoryGroup[category_group_id].categories \
        .each do |c|
          parent_categories[c.id] = c.name if c.id != category_id
        end

        parent_categories[nil] = '--'

        return parent_categories
      end

      ##
      # Redirects the user to the category groups overview and shows a message
      # about an invalid group being specified.
      #
      # @since 03-04-2012
      #
      def redirect_invalid_group
        message(:error, lang('category_groups.errors.invalid_group'))
        redirect(::Categories::Controller::CategoryGroups.r(:index))
      end

      ##
      # Redirects the user to the overview of the categories of a given group
      # and shows a message informing the user that the specified category was
      # invalid.
      #
      # @since 03-04-2012
      # @param [Fixnum] category_group_id The ID of the category group that the
      #  category belongs to.
      #
      def redirect_invalid_category(category_group_id)
        message(:error, lang('categories.errors.invalid_category'))
        redirect(
          ::Categories::Controller::Categories.r(:index, category_group_id)
        )
      end
    end # Category
  end # Helper
end # Ramaze
