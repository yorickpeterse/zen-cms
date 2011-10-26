require File.expand_path('../../../../../helper', __FILE__)

describe("Sections::Controller::Sections") do
  behaves_like :capybara

  index_url     = Sections::Controller::Sections.r(:index).to_s
  new_url       = Sections::Controller::Sections.r(:new).to_s
  edit_url      = Sections::Controller::Sections.r(:edit).to_s
  new_button    = lang('sections.buttons.new')
  save_button   = lang('sections.buttons.save')
  delete_button = lang('sections.buttons.delete')

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      Sections::Controller::Sections.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should == true
    response.status.should                                         == 403
  end

  it("No sections should exist") do
    message = lang('sections.messages.no_sections')

    visit(index_url)

    current_path.should == index_url
    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should == true
  end

  it("Create a new section") do
    select_plain = lang('zen_general.special.format_hash.plain')

    click_link(new_button)

    current_path.should == new_url

    # Check if the tabs are there
    page.has_selector?('.tabs ul').should == true

    # Fill in the form
    within('#section_form') do
      fill_in('name'       , :with => 'Spec section')
      fill_in('description', :with => 'Spec section description.')

      choose('form_comment_allow_0')
      choose('form_comment_require_account_1')
      choose('form_comment_moderate_0')
      select(select_plain, :from => 'form_comment_format')

      click_on(save_button)
    end

    # Validate the new page
    current_path.should =~ /#{edit_url}\/[0-9]+/
    page.find('input[name="name"]').value.should == 'Spec section'
  end

  it('Search for a section') do
    search_button = lang('zen_general.buttons.search')
    error         = lang('zen_general.errors.invalid_search')

    visit(index_url)

    within('#search_form') do
      fill_in('query', :with => 'Spec section')
      click_on(search_button)
    end

    page.has_content?(error).should          == false
    page.has_content?('Spec section').should == true

    within('#search_form') do
      fill_in('query', :with => 'does not exist')
      click_on(search_button)
    end

    page.has_content?(error).should          == false
    page.has_content?('Spec section').should == false
  end

  it("Edit an existing section") do
    visit(index_url)
    click_link('Spec section')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#section_form') do
      fill_in('name', :with => 'Spec section modified')
      click_on(save_button)
    end

    page.find('input[name="name"]').value.should == 'Spec section modified'
    page.find('input[name="slug"]').value.should == 'spec-section'
  end

  it("Edit an existing section with invalid data") do
    visit(index_url)
    click_link('Spec section')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#section_form') do
      fill_in('name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should == true
  end

  it('Delete a section without an ID specified') do
    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="section_ids[]"]').should == true
  end

  it("Delete an existing section") do
    visit(index_url)

    check('section_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should == false
  end

  it('Call the event new_section (before and after)') do
    event_name = nil

    Zen::Event.listen(:before_new_section) do |section|
      section.name += ' with event'
    end

    Zen::Event.listen(:after_new_section) do |section|
      event_name = section.name
    end

    visit(index_url)
    click_on(new_button)

    within('#section_form') do
      fill_in('name', :with => 'Section')

      choose('form_comment_allow_0')
      choose('form_comment_require_account_1')
      choose('form_comment_moderate_0')

      select(
        lang('zen_general.special.format_hash.plain'),
        :from => 'form_comment_format'
      )

      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Section with event'
    event_name.should                            == 'Section with event'

    Zen::Event.delete(:before_new_section, :after_new_section)
  end

  it('Call the event edit_section (before and after)') do
    event_name = nil

    Zen::Event.listen(:before_edit_section) do |section|
      section.name = 'Section modified'
    end

    Zen::Event.listen(:after_edit_section) do |section|
      event_name = section.name
    end

    visit(index_url)
    click_on('Section with event')

    within('#section_form') do
      click_on(save_button)
    end

    page.has_selector?('span.error').should      == false
    page.find('input[name="name"]').value.should == 'Section modified'
    event_name.should                            == 'Section modified'

    Zen::Event.delete(:before_edit_section, :after_edit_section)
  end

  it('Call the event delete_section (before and after)') do
    event_name  = nil
    event_name2 = nil
    message     = lang('sections.messages.no_sections')

    Zen::Event.listen(:before_delete_section) do |section|
      event_name = section.name
    end

    Zen::Event.listen(:after_delete_section) do |section|
      event_name2 = section.name
    end

    visit(index_url)
    check('section_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should           == true
    event_name.should                           == 'Section modified'
    event_name2.should                          == event_name
  end
end
