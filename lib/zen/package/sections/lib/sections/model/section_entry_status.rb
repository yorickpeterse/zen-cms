module Sections
  module Model
    ##
    # Model for managing the statuses of each section entry.
    #
    # @since  0.2.8
    #
    class SectionEntryStatus < Sequel::Model
      many_to_one :section_entry,
        :class => 'Sections::Model::SectionEntryStatus'
    end # SectionEntryStatus
  end # Model
end # Sections
