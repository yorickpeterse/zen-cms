require File.expand_path('../../../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'package/dashboard/widget')

##
# The specifications in this block run using Selenium so make sure you have
# Selenium and Firefox installed.
#
# Various specifications in this file contain calls to sleep(N). These calls are
# used because Mootools' Fx.Slide class has a certain lag time that prevents
# people from rapidly clicking the "Options" button.
#
describe 'Dashboard::Controller::Dashboard' do
  WebMock.disable!

  Capybara.current_driver = Capybara.javascript_driver
  dashboard_url           = Dashboard::Controller::Dashboard.r(:index).to_s

  behaves_like :capybara

  before do
    Dashboard::Model::Widget.filter(~{:name => 'welcome'}).destroy

    unless current_path =~ /#{dashboard_url}/
      Users::Model::User[:email => 'spec@domain.tld'] \
        .update(:widget_columns => 1)

      visit(dashboard_url)
    end
  end

  it 'Users should see the Welcome widget by default' do
    page.has_selector?('#widget_welcome').should                       == true
    page.has_content?(lang('dashboard.widgets.titles.welcome')).should == true

    page.has_content?(
      lang('dashboard.widgets.welcome.content.paragraph_1').split("\n")[0] \
        % Zen::VERSION
    ).should == true
  end

  it 'Users should be able to toggle the widget options menu' do
    script = "$('widget_options').getStyle('margin-top').toInt();"

    page.evaluate_script(script).to_i.should == 0

    # Show and hide the options container.
    click_button('toggle_options')
    sleep(1)

    click_button('toggle_options')
    sleep(1)

    page.evaluate_script(script).to_i.should < 0
  end

  it 'Users should be able to change the amount of widget columns' do
    script = "$('widget_welcome').getSize().x;"

    click_button('toggle_options')
    choose('widget_columns_1')

    old_width = page.evaluate_script(script).to_i

    # Switch to a 2 column based layout.
    choose('widget_columns_2')

    page.evaluate_script(script).to_i.should <= old_width / 2
    Users::Model::User[:email => 'spec@domain.tld'].widget_columns.should == 2

    # Switch to a 3 column based layout.
    choose('widget_columns_3')

    page.evaluate_script(script).to_i.should <= old_width / 3
    Users::Model::User[:email => 'spec@domain.tld'].widget_columns.should == 3

    # 4 column layout
    choose('widget_columns_4')

    page.evaluate_script(script).to_i.should <= old_width / 4
    Users::Model::User[:email => 'spec@domain.tld'].widget_columns.should == 4
  end

  it 'Users should be able to toggle the active widgets' do
    # When $() returns an existing element the type (as returned by typeOf()) is
    # "element". If the element doesn't exist the type is "null".
    script = "typeOf($('widget_welcome'));"
    user   = Users::Model::User[:email => 'spec@domain.tld']

    page.evaluate_script(script).should == 'element'

    Dashboard::Model::Widget[:name => 'welcome', :user_id => user.id].nil? \
      .should == false

    uncheck('toggle_widget_welcome')

    page.evaluate_script(script).should == 'null'

    Dashboard::Model::Widget[:name => 'welcome', :user_id => user.id].nil? \
      .should == true

    check('toggle_widget_welcome')

    page.evaluate_script(script).should == 'element'

    Dashboard::Model::Widget[:name => 'welcome', :user_id => user.id].nil? \
      .should == false
  end

  it 'Users should be able to re-arrange widgets' do
    script = "$$('.widget:first-child')[0].get('id');"
    user   = Users::Model::User[:email => 'spec@domain.tld']

    click_button('toggle_options')
    check('toggle_widget_spec')

    # Check if the standard order and amount of widgets is correct.
    page.evaluate_script(script).should == 'widget_welcome'

    page.evaluate_script("$$('.widget').length;").to_i.should == 2

    # Drag the second widget to the place of the first one.
    page.find('#widget_spec header').drag_to(page.find('#widget_welcome header'))

    page.evaluate_script(script).should == 'widget_spec'

    Dashboard::Model::Widget[:name => 'spec', :user_id => user.id] \
      .order.should == 0

    Dashboard::Model::Widget[:name => 'welcome', :user_id => user.id] \
      .order.should == 1

    # Put the widget order back in place.
    page.find('#widget_welcome header').drag_to(page.find('#widget_spec header'))

    Dashboard::Model::Widget[:name => 'spec', :user_id => user.id] \
      .order.should == 1

    Dashboard::Model::Widget[:name => 'welcome', :user_id => user.id] \
      .order.should == 0
  end

  Capybara.use_default_driver
  WebMock.enable!
end
