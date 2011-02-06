module Comments
  module Models
    ##
    # Model that represents a single comment. This model has the following relations:
    #
    # * section entry (many to one)
    # * user (many to one)
    #
    # The following plugins are used:
    #
    # * timestamps 
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Comment < Sequel::Model
      many_to_one :section_entry, :class => "Sections::Models::SectionEntry"
      many_to_one :user,          :class => "Users::Models::User"
      
      plugin :timestamps, :create => :created_at, :update => :updated_at
      
      ##
      # Specify the validation rules for each comment.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def validate
        validates_presence :comment
        validates_presence :email
      end
    end
  end
end
