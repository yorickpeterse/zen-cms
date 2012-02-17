require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('category_groups')

describe "Categories::Controller::CategoryGroups" do
  behaves_like :capybara

  index_url     = Categories::Controller::CategoryGroups.r(:index).to_s
  new_url       = Categories::Controller::CategoryGroups.r(:new).to_s
  edit_url      = Categories::Controller::CategoryGroups.r(:edit).to_s
  save_button   = lang('category_groups.buttons.save')
  delete_button = lang('category_groups.buttons.delete')

  after do
    Zen::Event.delete(
      :before_new_category_group,
      :after_new_category_group,
      :before_edit_category_group,
      :after_edit_category_group,
      :before_delete_category_group,
      :after_delete_category_group
    )
  end

  it 'Submit a form without a CSRF token' do
    response = page.driver.post(
      Categories::Controller::CategoryGroups.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  it 'Find no existing category groups' do
    message = lang('category_groups.messages.no_groups')

    visit(index_url)

    page.has_content?(message).should           == true
    page.has_selector?('table tbody tr').should == false
  end

  it "Create a new category group" do
    new_button  = lang('category_groups.buttons.new')
    name        = 'Spec category group'
    event_name  = nil
    event_name2 = nil

    Zen::Event.listen(:before_new_category_group) do |group|
      event_name = group.name
    end

    Zen::Event.listen(:after_new_category_group) do |group|
      event_name2 = group.name
    end

    visit(index_url)
    click_link(new_button)

    current_path.should == new_url

    within('#category_group_form') do
      fill_in('name', :with => name)
      click_on(save_button)
    end

    current_path.should                          =~ /#{edit_url}\/[0-9]+/
    page.find('input[name="name"]').value.should == name

    # Check if the events were run properly
    event_name.should  == name
    event_name2.should == event_name
  end

  it 'Search for a category group' do
    visit(index_url)
    search_button = lang('zen_general.buttons.search')
    error         = lang('zen_general.errors.invalid_search')

    within('#search_form') do
      fill_in('query', :with => 'Spec category group')
      click_on(search_button)
    end

    page.has_content?(error).should                 == false
    page.has_content?('Spec category group').should == true

    within('#search_form') do
      fill_in('query', :with => 'does not exist')
      click_on(search_button)
    end

    page.has_content?(error).should                 == false
    page.has_content?('Spec category group').should == false
    page.has_selector?('table tbody tr').should     == false
  end

  it "Edit an existing category group" do
    event_name  = nil
    event_name2 = nil
    name        = 'Spec category group 123'

    Zen::Event.listen(:before_edit_category_group) do |group|
      event_name = group.name
    end

    Zen::Event.listen(:after_edit_category_group) do |group|
      event_name2 = group.name
    end

    visit(index_url)
    click_link('Spec category group')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#category_group_form') do
      fill_in('name', :with => name)
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should == name

    event_name.should  == name
    event_name2.should == event_name

    # This time an event should modify the name of a group
    Zen::Event.listen(:before_edit_category_group) do |group|
      group.name = 'Spec category group modified'
    end

    within('#category_group_form') do
      click_on(save_button)
    end

    page.find('input[name="name"]') \
      .value.should == 'Spec category group modified'
  end

  it "Edit an existing category group with invalid data" do
    visit(index_url)
    click_link('Spec category group')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#category_group_form') do
      fill_in('name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should == true
  end

  enable_javascript

  it 'Automatically save a category group' do
    visit(index_url)
    click_link('Spec category group')

    within('#category_group_form') do
      fill_in('name', :with => 'Spec category group autosave')
    end

    page.evaluate_script(
      "new Zen.Autosave(
        $('category_group_form'),
        $('category_group_form').get('data-autosave-url'),
        {interval: 3000}
      );"
    )

    sleep(6)

    page.has_selector?('span.error').should == false

    # Check if the content was actually saved.
    visit(index_url)

    page.has_content?('Spec category group autosave').should == true

    click_link('Spec category group autosave')

    within('#category_group_form') do
      fill_in('name', :with => 'Spec category group modified')
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Spec category group modified'
  end

  disable_javascript

  it 'Fail to delete a category group without an ID' do
    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="category_group_ids[]"]').should == true
  end

  it "Delete an existing category group" do
    message     = lang('category_groups.messages.no_groups')
    event_name  = nil
    event_name2 = nil

    Zen::Event.listen(:before_delete_category_group) do |group|
      event_name = group.name
    end

    Zen::Event.listen(:after_delete_category_group) do |group|
      event_name2 = group.name
    end

    visit(index_url)
    check('category_group_ids[]')

    click_on(delete_button)

    page.has_content?(message).should           == true
    page.has_selector?('table tbody tr').should == false

    event_name.should  == 'Spec category group modified'
    event_name2.should == event_name
  end
end
