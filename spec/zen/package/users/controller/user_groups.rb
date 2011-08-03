require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('user_groups')

describe("Users::Controller::UserGroups") do
  behaves_like :capybara

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      Users::Controller::UserGroups.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should === true
    response.status.should                                         === 403
  end

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

  it("Edit an existing user group with invalid data") do
    index_url    = Users::Controller::UserGroups.r(:index).to_s
    save_button  = lang('user_groups.buttons.save')

    visit(index_url)
    click_link('Spec group')

    within('#user_group_form') do
      fill_in('name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('label[for="form_name"] span.error').should === true
  end

  it("Delete an existing user group") do
    index_url     = Users::Controller::UserGroups.r(:index).to_s
    delete_button = lang('user_groups.buttons.delete')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="user_group_ids[]"]').should === true
    page.all('table tbody tr').count.should                     === 2
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
