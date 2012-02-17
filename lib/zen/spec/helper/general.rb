module Zen
  module Spec
    module Helper
      ##
      # Module providing general spec helpers.
      #
      # @since 18-02-2012
      #
      module General
        ##
        # Allows developers to create stubbed objects similar to Mocha's stub() method.
        #
        # @example
        #  obj = stub(:language => 'Ruby')
        #  puts obj.language # => "Ruby"
        #
        # @since  0.2.8
        # @param  [Hash] attributes A hash containing all the attributes to set and
        # their values.
        # @return [Class]
        #
        def stub(attributes)
          obj = Struct.new(*attributes.keys).new

          attributes.each do |k, v|
            obj.send("#{k}=", v)
          end

          return obj
        end

        ##
        # Returns a hash with a stubbed custom field and a stubbed custom field value.
        #
        # @since  0.2.8
        # @param  [String] field_type_name The name of the field type.
        # @param  [Hash] options Additional options to pass to the stub() call for the
        # custom field.
        # @return [Hash]
        #
        def stub_custom_field(field_type_name, options = {})
          custom_field_type = CustomFields::Model::CustomFieldType[
            :name => field_type_name
          ]

          options = {
            :id                    => 1,
            :name                  => 'Field',
            :slug                  => 'field',
            :description           => 'A stubbed field',
            :sort_order            => 0,
            :format                => 'markdown',
            :required              => false,
            :text_editor           => false,
            :textarea_rows         => nil,
            :text_limit            => 100,
            :custom_field_group_id => 1,
            :custom_field_type_id  => custom_field_type.id,
            :custom_field_type     => custom_field_type
          }.merge(options)

          return {
            :custom_field       => stub(options),
            :custom_field_value => stub(
              :id               => 1,
              :value            => 'Ruby',
              :custom_field_id  => 1,
              :section_entry_id => 1
            )
          }
        end
      end # General
    end # Helper
  end # Spec
end # Zen
