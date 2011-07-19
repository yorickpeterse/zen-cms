require File.expand_path('../../../../../helper', __FILE__)

describe('Ramaze::Helper::CustomField') do
  behaves_like :capybara

  # Create the test data and ensure it's valid. The data that is created is a
  # custom field group and a single custom field.
  it('Create the test data') do
    type   = CustomFields::Model::CustomFieldType[:name => 'textbox']
    @group = CustomFields::Model::CustomFieldGroup.create(
      :name => 'Spec group'
    )

    @field = CustomFields::Model::CustomField.create(
      :name                  => 'Spec field',
      :format                => 'markdown',
      :text_editor           => false,
      :required              => false,
      :custom_field_group_id => @group.id,
      :custom_field_type_id  => type.id
    )

    @group.name.should === 'Spec group'
    @field.name.should === 'Spec field'

    # Check if the data is actually in the database
    CustomFields::Model::CustomField[:name => 'Spec field'] \
      .nil?.should === false

    CustomFields::Model::CustomFieldGroup[:name => 'Spec group'] \
      .nil?.should === false
  end

  # Validates a field group by navigating to a URL that normally allows the user
  # to edit an existing group. The group tested in this specification is valid.
  it('Validate a valid custom field group') do
    url = CustomFields::Controller::CustomFieldGroups.r(:edit, @group.id).to_s

    visit(url)

    current_path.should === url
  end

  # Similar to the spec above but instead of validating a valid group it instead
  # validates an invalid group. This should result in the user being redirected
  # back to the overview of all the existing groups.
  it('Validate an invalid custom field group') do
    url   = CustomFields::Controller::CustomFieldGroups \
      .r(:edit, @group.id + 1).to_s
    
    index = CustomFields::Controller::CustomFieldGroups \
      .r(:index).to_s

    visit(url)

    current_path.should === index
  end

  # Validates a single field. This field should be valid and thus the user is
  # able to edit it.
  it('Validate a valid custom field') do
    url = CustomFields::Controller::CustomFields \
      .r(:edit, @group.id, @field.id).to_s

    visit(url)

    current_path.should === url
  end

  # Validates an invalid field. The result is that the user will be redirected
  # back to the overview of all fields for a particular group (the one that was
  # set in the URL).
  it('Validate an invalid custom field') do
    url = CustomFields::Controller::CustomFields \
      .r(:edit, @group.id, @field.id + 1).to_s

    index = CustomFields::Controller::CustomFields.r(:index, @group.id).to_s

    visit(url)

    current_path.should === index
  end

  it('Delete the test data') do
    @field.destroy
    @group.destroy

    CustomFields::Model::CustomField[:name => 'Spec field'].should      === nil
    CustomFields::Model::CustomFieldGroup[:name => 'Spec group'].should === nil
  end
end
