require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('user_groups')

describe("Users::Controller::UserGroups", :type => :acceptance, :auto_login => true) do

  it("A single user group should exist") do
    index_url = Users::Controller::UserGroups.r(:index).to_s
    message   = lang('user_groups.messages.no_groups')

    visit(index_url)

    page.has_content?(message).should           === false
    page.has_selector?('table tbody tr').should === true
    page.all('table tbody tr').count.should     === 1
  end

  it("Create a new user group") do
    index_url   = Users::Controller::UserGroups.r(:index).to_s
    save_button = lang('user_groups.buttons.save')
    new_button  = lang('user_groups.buttons.new')

    visit(index_url)
    click_link(new_button)

    within('#user_group_form') do
      fill_in('name', :with => 'Spec group')
      choose('form_super_group_0')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should     === 'Spec group'
    page.find('#form_super_group_0').checked?.should === 'checked'
  end

  it("Edit an existing user group") do
    index_url    = Users::Controller::UserGroups.r(:index).to_s
    save_button  = lang('user_groups.buttons.save')

    visit(index_url)
    click_link('Spec group')

    within('#user_group_form') do
      fill_in('name', :with => 'Spec group modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should === 'Spec group modified'
  end

  it("Delete an existing user group") do
    index_url     = Users::Controller::UserGroups.r(:index).to_s
    delete_button = lang('user_groups.buttons.delete')

    visit(index_url)

    within('table tbody tr:last-child') do
      check('user_group_ids[]')
    end

    click_on(delete_button)

    page.all('table tbody tr').count.should === 1
  end

end
