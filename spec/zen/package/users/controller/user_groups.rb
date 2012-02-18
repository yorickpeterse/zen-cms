require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('user_groups')

describe 'Users::Controller::UserGroups' do
  behaves_like :capybara

  index_url     = Users::Controller::UserGroups.r(:index).to_s
  save_button   = lang('user_groups.buttons.save')
  new_button    = lang('user_groups.buttons.new')
  delete_button = lang('user_groups.buttons.delete')

  it 'Submit a form without a CSRF token' do
    response = page.driver.post(
      Users::Controller::UserGroups.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  it 'Find a single user group' do
    message = lang('user_groups.messages.no_groups')

    visit(index_url)

    page.has_content?(message).should           == false
    page.has_selector?('table tbody tr').should == true
    page.all('table tbody tr').count.should     == 1
  end

  it 'Create a new user group' do
    visit(index_url)
    click_link(new_button)

    within '#user_group_form' do
      fill_in('name', :with => 'Spec group')
      choose('form_super_group_0')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should     == 'Spec group'
    page.find('#form_super_group_0').checked?.should == 'checked'
  end

  it 'Search for a user group' do
    search_button = lang('zen_general.buttons.search')
    error         = lang('zen_general.errors.invalid_search')

    visit(index_url)

    within '#search_form' do
      fill_in('query', :with => 'Spec group')
      click_on(search_button)
    end

    page.has_content?(error).should        == false
    page.has_content?('Spec group').should == true

    within '#search_form' do
      fill_in('query', :with => 'does not exist')
      click_on(search_button)
    end

    page.has_content?(error).should        == false
    page.has_content?('Spec group').should == false
  end

  it 'Edit an existing user group' do
    group = Users::Model::UserGroup[:name => 'Spec group']
    path  = Users::Controller::UserGroups.r(:edit, group.id).to_s

    visit(index_url)
    click_link('Spec group')

    current_path.should == path

    within '#user_group_form' do
      fill_in('name', :with => 'Spec group modified')
      check('permission_show_user')
      click_on(save_button)
    end

    current_path.should == path

    page.has_selector?('span.error').should            == false
    page.find('input[name="name"]').value.should       == 'Spec group modified'
    page.find('#permission_show_user').checked?.should == 'checked'
  end

  it 'Edit an existing user group with invalid data' do
    visit(index_url)
    click_link('Spec group')

    within '#user_group_form' do
      fill_in('name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('label[for="form_name"] span.error').should == true
  end

  it 'Delete a group without an ID' do
    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="user_group_ids[]"]').should == true
    page.all('table tbody tr').count.should                     == 2
  end

  it 'Delete an existing user group' do
    visit(index_url)

    within 'table tbody tr:last-child' do
      check('user_group_ids[]')
    end

    click_on(delete_button)

    page.all('table tbody tr').count.should == 1
  end

  it 'Call the event new_user_group (before and after)' do
    event_name = nil

    Zen::Event.listen(:before_new_user_group) do |user_group|
      user_group.name += ' with event'
    end

    Zen::Event.listen(:after_new_user_group) do |user_group|
      event_name = user_group.name
    end

    visit(index_url)
    click_on(new_button)

    within '#user_group_form' do
      fill_in('name', :with => 'Group')
      choose('form_super_group_0')
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Group with event'
    event_name.should                            == 'Group with event'

    Zen::Event.delete(:before_new_user_group, :after_new_user_group)
  end

  it 'Call the event edit_user_group (before and after)' do
    event_name = nil

    Zen::Event.listen(:before_edit_user_group) do |user_group|
      user_group.name = 'Group modified'
    end

    Zen::Event.listen(:after_edit_user_group) do |user_group|
      event_name = user_group.name
    end

    visit(index_url)
    click_on('Group with event')

    within '#user_group_form' do
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Group modified'
    event_name.should                            == 'Group modified'

    Zen::Event.delete(:before_edit_user_group, :after_edit_user_group)
  end

  it 'Call the event delete_user_group (before and after)' do
    event_name  = nil
    event_name2 = nil

    Zen::Event.listen(:before_delete_user_group) do |user_group|
      event_name = user_group.name
    end

    Zen::Event.listen(:after_delete_user_group) do |user_group|
      event_name2 = user_group.name
    end

    visit(index_url)

    within 'table tbody tr:last-child' do
      check('user_group_ids[]')
    end

    click_on(delete_button)

    page.has_content?('Group modified').should == false
    event_name.should                          == 'Group modified'
    event_name2.should                         == event_name

    Zen::Event.delete(:before_delete_user_group, :after_delete_user_group)
  end
end
