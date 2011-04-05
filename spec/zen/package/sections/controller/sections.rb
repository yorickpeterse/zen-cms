require File.expand_path('../../../../../helper', __FILE__)

Zen::Language.load('sections')

describe("Sections::Controllers::Sections", :type => :acceptance, :auto_login => true) do
  
  it("No sections should exist") do
    section_url = Sections::Controllers::Sections.r(:index).to_s
    message     = lang('sections.messages.no_sections')

    current_path.should == section_url
    page.has_selector?('table tbody tr').should == false
    page.has_content?(message).should == true
  end

  it("Create a new section") do
    new_url        = Sections::Controllers::Sections.r(:new).to_s
    edit_url       = Sections::Controllers::Sections.r(:edit).to_s
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
    index_url  = Sections::Controllers::Sections.r(:index).to_s
    edit_url   = Sections::Controllers::Sections.r(:edit).to_s
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

  it("Delete an existing section") do
    index_url     = Sections::Controllers::Sections.r(:index).to_s
    delete_button = lang('sections.buttons.delete')

    visit(index_url)

    # Check the section and delete it
    check('section_ids[]')
    click_on(delete_button)

    # If everything went ok we should no longer have any sections
    page.has_selector?('table tbody tr').should === false
  end

end
