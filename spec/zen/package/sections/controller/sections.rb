require File.expand_path('../../../../../helper', __FILE__)

describe("Sections::Controller::Sections") do
  behaves_like :capybara

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      Sections::Controller::Sections.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should === true
    response.status.should                                         === 403
  end

  it("No sections should exist") do
    section_url = Sections::Controller::Sections.r(:index).to_s
    message     = lang('sections.messages.no_sections')

    visit(section_url)

    current_path.should == section_url
    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should == true
  end

  it("Create a new section") do
    new_url        = Sections::Controller::Sections.r(:new).to_s
    edit_url       = Sections::Controller::Sections.r(:edit).to_s
    new_button     = lang('sections.buttons.new')
    select_plain   = lang('zen_general.special.format_hash.plain')
    submit_button  = lang('sections.buttons.save')

    click_link(new_button)

    current_path.should == new_url

    # Check if the tabs are there
    page.has_selector?('.tabs ul').should === true

    # Fill in the form
    within('#section_form') do
      fill_in('name'       , :with => 'Spec section')
      fill_in('description', :with => 'Spec section description.')

      choose('form_comment_allow_0')
      choose('form_comment_require_account_1')
      choose('form_comment_moderate_0')
      select(select_plain, :from => 'form_comment_format')

      click_on(submit_button)
    end

    # Validate the new page
    current_path.should =~ /#{edit_url}\/[0-9]+/
    page.find('input[name="name"]').value.should === 'Spec section'
  end

  it("Edit an existing section") do
    index_url  = Sections::Controller::Sections.r(:index).to_s
    edit_url   = Sections::Controller::Sections.r(:edit).to_s
    submit     = lang('sections.buttons.save')

    visit(index_url)
    click_link('Spec section')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#section_form') do
      fill_in('name', :with => 'Spec section modified')
      click_on(submit)
    end

    page.find('input[name="name"]').value.should === 'Spec section modified'
    page.find('input[name="slug"]').value.should === 'spec-section'
  end

  it("Edit an existing section with invalid data") do
    index_url  = Sections::Controller::Sections.r(:index).to_s
    edit_url   = Sections::Controller::Sections.r(:edit).to_s
    submit     = lang('sections.buttons.save')

    visit(index_url)
    click_link('Spec section')

    current_path.should =~ /#{edit_url}\/[0-9]+/

    within('#section_form') do
      fill_in('name', :with => '')
      click_on(submit)
    end

    page.has_selector?('span.error').should === true
  end

  it('Delete a section without an ID specified') do
    index_url     = Sections::Controller::Sections.r(:index).to_s
    delete_button = lang('sections.buttons.delete')

    visit(index_url)
    click_on(delete_button)

    page.has_selector?('input[name="section_ids[]"]').should === true
  end

  it("Delete an existing section") do
    index_url     = Sections::Controller::Sections.r(:index).to_s
    delete_button = lang('sections.buttons.delete')

    visit(index_url)

    check('section_ids[]')
    click_on(delete_button)

    page.has_selector?('table tbody tr').should === false
  end
end
