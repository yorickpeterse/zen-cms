require File.expand_path('../../../../../helper', __FILE__)

describe('Ramaze::Helper::CustomField') do
  behaves_like :capybara

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

  @group.name.should == 'Spec group'
  @field.name.should == 'Spec field'

  should('validate a valid custom field group') do
    url = CustomFields::Controller::CustomFieldGroups.r(:edit, @group.id).to_s

    visit(url)

    current_path.should == url
  end

  should('validate an invalid custom field group') do
    url   = CustomFields::Controller::CustomFieldGroups \
      .r(:edit, @group.id + 1).to_s

    index = CustomFields::Controller::CustomFieldGroups \
      .r(:index).to_s

    visit(url)

    current_path.should == index
  end

  should('validate a valid custom field') do
    url = CustomFields::Controller::CustomFields \
      .r(:edit, @group.id, @field.id).to_s

    visit(url)

    current_path.should == url
  end

  should('validate an invalid custom field') do
    url = CustomFields::Controller::CustomFields \
      .r(:edit, @group.id, @field.id + 1).to_s

    index = CustomFields::Controller::CustomFields.r(:index, @group.id).to_s

    visit(url)

    current_path.should == index
  end

  should('validate a valid custom field type') do
    type = CustomFields::Model::CustomFieldType[:name => 'textbox']
    url  = CustomFields::Controller::CustomFieldTypes.r(:edit, type.id).to_s

    visit(url)

    current_path.should == url
  end

  should('validate an invalid custom field type') do
    type = CustomFields::Model::CustomFieldType[:name => 'textbox']

    visit(
      CustomFields::Controller::CustomFieldTypes.r(:edit, type.id + 100).to_s
    )

    current_path.should == CustomFields::Controller::CustomFieldTypes.r(
      :index
    ).to_s
  end

  @field.destroy
  @group.destroy
end # describe
