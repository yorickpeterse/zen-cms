require File.expand_path('../../../../helper', __FILE__)

describe('CustomFields::BlueFormParameters') do
  behaves_like :capybara

  should('generate the parameters for input_text()') do
    stubbed = stub_custom_field('textbox')
    params  = CustomFields::BlueFormParameters.input_text(
      stubbed[:custom_field],
      stubbed[:custom_field_value]
    )

    params[0].should == :input_text
    params[1].should == stubbed[:custom_field].name
    params[2].should == "custom_field_value_#{stubbed[:custom_field].id}"

    params[3][:value].should         == stubbed[:custom_field_value].value
    params[3][:maxlength].should     == stubbed[:custom_field].text_limit
    params[3][:'data-format'].should == nil
    params[3][:title].should   == stubbed[:custom_field].description
    params[3].key?(:class).should    == false
  end

  should('generate the parameters for input_password()') do
    stubbed = stub_custom_field('password')
    params  = CustomFields::BlueFormParameters.input_password(
      stubbed[:custom_field],
      stubbed[:custom_field_value]
    )

    params[0].should == :input_password
    params[1].should == stubbed[:custom_field].name
    params[2].should == "custom_field_value_#{stubbed[:custom_field].id}"

    params[3][:value].should              == stubbed[:custom_field_value].value
    params[3].key?(:'data-format').should == false
  end

  should('generate the parameters for textarea()') do
    stubbed = stub_custom_field(
      'textarea',
      :text_editor   => true,
      :textarea_rows => 10
    )

    params = CustomFields::BlueFormParameters.textarea(
      stubbed[:custom_field],
      stubbed[:custom_field_value]
    )

    params[0].should == :textarea
    params[1].should == stubbed[:custom_field].name
    params[2].should == "custom_field_value_#{stubbed[:custom_field].id}"

    params[3][:class].should         == 'text_editor'
    params[3][:'data-format'].should == stubbed[:custom_field].format
    params[3][:rows].should          == stubbed[:custom_field].textarea_rows

    # Try again but with the text editor disabled.
    stubbed = stub_custom_field('textarea',)
    params  = CustomFields::BlueFormParameters.textarea(
      stubbed[:custom_field],
      stubbed[:custom_field_value]
    )

    params[3][:class].empty?.should == true
  end

  should('generate the parameters for input_radio()') do
    stubbed = stub_custom_field(
      'radio',
      :possible_values => "ruby|Ruby\npython|Python"
    )

    params = CustomFields::BlueFormParameters.input_radio(
      stubbed[:custom_field],
      stubbed[:custom_field_value]
    )

    params[0].should == :input_radio
    params[1].should == stubbed[:custom_field].name
    params[2].should == "custom_field_value_#{stubbed[:custom_field].id}"
    params[3].should == stubbed[:custom_field_value].value

    params[4][:values]['ruby'].should   == 'Ruby'
    params[4][:values]['python'].should == 'Python'

    # Check if the correct parameters are generated with a different set of
    # possible values.
    stubbed = stub_custom_field(
      'radio',
      :possible_values => "ruby\npython"
    )

    params = CustomFields::BlueFormParameters.input_radio(
      stubbed[:custom_field],
      stubbed[:custom_field_value]
    )

    params[4][:values]['ruby'].should   == 'ruby'
    params[4][:values]['python'].should == 'python'
  end

  should('generate the parameters for input_checkbox()') do
    stubbed = stub_custom_field(
      'checkbox',
      :possible_values => "ruby|Ruby\npython|Python"
    )

    stubbed[:custom_field_value].value = ['Ruby', 'Python']

    params = CustomFields::BlueFormParameters.input_radio(
      stubbed[:custom_field],
      stubbed[:custom_field_value]
    )

    params[0].should == :input_radio
    params[1].should == stubbed[:custom_field].name
    params[2].should == "custom_field_value_#{stubbed[:custom_field].id}"

    params[3].class.should              == Array
    params[3].include?('Ruby').should   == true
    params[3].include?('Python').should == true
  end

  should('generate the parameters for select()') do
    stubbed = stub_custom_field(
      'select',
      :possible_values => "ruby|Ruby\npython|Python"
    )

    params = CustomFields::BlueFormParameters.select(
      stubbed[:custom_field],
      stubbed[:custom_field_value]
    )

    params[0].should == :select
    params[1].should == stubbed[:custom_field].name
    params[2].should == "custom_field_value_#{stubbed[:custom_field].id}"

    params[3][:selected].should         == stubbed[:custom_field_value].value
    params[3][:size].should             == 1
    params[3][:values]['ruby'].should   == 'Ruby'
    params[3][:values]['python'].should == 'Python'

    # Create the parameters using the same string as the keys and values.
    stubbed = stub_custom_field(
      'select',
      :possible_values => "ruby\npython"
    )

    params = CustomFields::BlueFormParameters.select(
      stubbed[:custom_field],
      stubbed[:custom_field_value]
    )

    params[3][:values]['ruby'].should   == 'ruby'
    params[3][:values]['python'].should == 'python'
  end

  should('generate the parameters for select_multiple()') do
    stubbed = stub_custom_field(
      'select_multiple',
      :possible_values => "ruby|Ruby\npython|Python"
    )

    stubbed[:custom_field_value].value = ['Ruby', 'Python']

    params = CustomFields::BlueFormParameters.select_multiple(
      stubbed[:custom_field],
      stubbed[:custom_field_value]
    )

    params[0].should == :select
    params[1].should == stubbed[:custom_field].name
    params[2].should == "custom_field_value_#{stubbed[:custom_field].id}"

    params[3][:selected].should         == ['Ruby', 'Python']
    params[3][:values]['Ruby'].should   == 'ruby'
    params[3][:values]['Python'].should == 'python'
    params[3][:multiple].should         == :multiple
  end
end # describe
