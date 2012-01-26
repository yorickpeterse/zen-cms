require File.expand_path('../../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'package/dashboard/widget')
require File.join(Zen::FIXTURES, 'package/dashboard/controller/widget')

describe 'Dashboard::Widget' do
  behaves_like :capybara

  widget = Dashboard::Model::Widget.create(
    :name    => 'spec',
    :user_id => Users::Model::User[:email => 'spec@domain.tld'].id,
    :order   => 0
  )

  it 'Retrieve an existing widget' do
    Dashboard::Widget[:spec].title.should  == 'Spec'
    Dashboard::Widget['spec'].title.should == 'Spec'
  end

  it 'Retrieve a non existing widget' do
    should.raise?(Dashboard::WidgetError) do
      Dashboard::Widget[:does_not_exist]
    end

    should.raise?(Dashboard::WidgetError) do
      Dashboard::Widget['does_not_exist']
    end
  end

  it 'Build the HTML for all widgets' do
    visit('/admin/spec-widget')

    page.body.should =~ /<section class="widget" id="widget_spec">/
    page.body.should =~ /<div class="body">/
  end

  it 'Build the HTML for the column radio buttons' do
    visit('/admin/spec-widget/columns')

    str = '<input name="widget_columns" type="radio" value="%s" ' \
      'id="widget_columns_%s">'

    page.has_selector?('input[id="widget_columns_1"]').should == true
    page.has_selector?('input[id="widget_columns_2"]').should == true
    page.has_selector?('input[id="widget_columns_3"]').should == true
    page.has_selector?('input[id="widget_columns_4"]').should == true
  end

  it 'Build the HTML for the active widget checkboxes' do
    visit('/admin/spec-widget/checkbox')

    page.has_selector?('input[id="toggle_widget_spec"]').should    == true
    page.has_selector?('input[id="toggle_widget_welcome"]').should == true
  end

  widget.destroy
end
