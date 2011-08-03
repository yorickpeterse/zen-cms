Sequel.migration do
  # Updates the database with the changes specified in the block.
  up do
    rename_column(:custom_fields, :visual_editor, :text_editor)

    create_table(:custom_field_methods) do
      primary_key :id

      String :name, :unique => true
    end

    # Insert all the possible methods.
    Zen.database[:custom_field_methods].insert_multiple([
      {:name => 'input_text'},
      {:name => 'input_checkbox'},
      {:name => 'input_radio'},
      {:name => 'input_password'},
      {:name => 'textarea'},
      {:name => 'select'},
      {:name => 'select_multiple'},
    ])

    create_table(:custom_field_types) do
      primary_key :id

      String    :name           , :null => false
      String    :language_string, :null => false
      String    :css_class

      TrueClass :serialize   , :null => false, :default => false
      TrueClass :allow_markup, :null => false, :default => false

      foreign_key(
        :custom_field_method_id,
        :custom_field_methods,
        :on_delete => :cascade,
        :on_update => :cascade,
        :key       => :id
      )
    end

    # For some reason foreign keys didn't work for this column.
    add_column(
      :custom_fields,
      :custom_field_type_id,
      Integer,
      :index => true
    )

    field_methods = {}

    Zen.database[:custom_field_methods].each do |m|
      field_methods[m[:name]] = m[:id]
    end

    default_types = [
      {
        :name                   => 'textbox',
        :language_string        => 'custom_fields.special.type_hash.textbox',
        :custom_field_method_id => field_methods['input_text']
      },
      {
        :name                   => 'checkbox',
        :language_string        => 'custom_fields.special.type_hash.checkbox',
        :serialize              => true,
        :custom_field_method_id => field_methods['input_checkbox']
      },
      {
        :name                   => 'radio',
        :language_string        => 'custom_fields.special.type_hash.radio',
        :custom_field_method_id => field_methods['input_radio']
      },
      {
        :name                   => 'password',
        :language_string        => 'custom_fields.special.type_hash.password',
        :custom_field_method_id => field_methods['input_password']
      },
      {
        :name                   => 'textarea',
        :language_string        => 'custom_fields.special.type_hash.textarea',
        :allow_markup           => true,
        :custom_field_method_id => field_methods['textarea'],
        :css_class              => 'text_editor'
      },
      {
        :name                   => 'select',
        :language_string        => 'custom_fields.special.type_hash.select',
        :custom_field_method_id => field_methods['select']
      },
      {
        :name                   => 'select_multiple',
        :language_string        => 'custom_fields.special.type_hash.select_multiple',
        :serialize              => true,
        :custom_field_method_id => field_methods['select_multiple']
      },
      {
        :name                   => 'date',
        :language_string        => 'custom_fields.special.type_hash.date',
        :custom_field_method_id => field_methods['input_text'],
        :css_class              => 'date'
      }
    ]

    # Insert the default fields
    Zen.database[:custom_field_types].insert_multiple(default_types)

    field_types = {}

    Zen.database[:custom_field_types].each do |t|
      field_types[t[:name]] = t[:id]
    end

    # Replace the text values with the correct IDs
    Zen.database[:custom_fields].each do |field|
      Zen.database[:custom_fields].filter(:id => field[:id]).update(
        :custom_field_type_id => field_types[field[:type]]
      )
    end

    # Drop the text based column now that all the data has been migrated.
    drop_column(:custom_fields, :type)
  end

  # Reverts the changes made in the up() block.
  down do
    rename_column(:custom_fields, :text_editor, :visual_editor)

    types  = {}
    fields = Zen.database[:custom_fields].all

    Zen.database[:custom_field_types].each do |type|
      types[type[:id]] = type[:name]
    end

    # Put the string based fields type back in place
    add_column(:custom_fields, :type, String)

    fields.each do |field|
      Zen.database[:custom_fields].filter(:id => field[:id]).update(
        :type => types[field[:custom_field_type_id]]
      )
    end

    drop_column(:custom_fields, :custom_field_type_id)
    drop_table(:custom_field_types)
    drop_table(:custom_field_methods)
  end
end
