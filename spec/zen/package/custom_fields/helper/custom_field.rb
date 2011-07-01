require File.expand_path('../../../../../helper', __FILE__)

describe('Ramaze::Helper::CustomField') do
  behaves_like :capybara

  it('Create the test data') do
    @group = CustomFields::Model::CustomFieldGroup.create(
      :name => 'Spec group'
    )

    @field = CustomFields::Model::CustomField.create(
      :name          => 'Spec field',
      :type          => 'textbox',
      :format        => 'markdown',
      :visual_editor => false,
      :required      => false
    )

    @group.name.should === 'Spec group'
    @field.name.should === 'Spec field'
  end

  it('Validate a valid custom field group') do
    url = CustomFields::Controller::CustomFieldGroups.r(:edit, @group.id).to_s

    visit(url)

    current_path.should === url
  end

  it('Validate an invalid custom field group') do
    url   = CustomFields::Controller::CustomFieldGroups \
      .r(:edit, @group.id + 1).to_s
    
    index = CustomFields::Controller::CustomFieldGroups \
      .r(:index).to_s

    visit(url)

    current_path.should === index
  end

  it('Validate a valid custom field') do
    url = CustomFields::Controller::CustomFields \
      .r(:edit, @group.id, @field.id).to_s

    visit(url)

    current_path.should === url
  end

  it('Validate an invalid custom field') do
    url = CustomFields::Controller::CustomFields \
      .r(:edit, @group.id, @field.id + 1).to_s

    index = CustomFields::Controller::CustomFields.r(:index, @group.id).to_s

    visit(url)

    current_path.should === index
  end

  it('Delete the test data') do
    @group.destroy
    @field.destroy

    CustomFields::Model::CustomFieldGroup[:name => 'Spec group'].should === nil
    CustomFields::Model::CustomField[:name => 'Spec field'].should      === nil
  end
end
