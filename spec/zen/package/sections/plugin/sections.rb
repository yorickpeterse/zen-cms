require File.expand_path('../../../../../helper', __FILE__)

describe('Sections::Plugin::Sections') do
  extend ::Sections::Model

  it('Create the test data') do
    Testdata[:section_1] = Section.create(
      :name                    => 'Spec', 
      :comment_allow           => true, 
      :comment_require_account => false,
      :comment_moderate        => false, 
      :comment_format          => 'plain'
    )

    Testdata[:section_2] = Section.create(
      :name                    => 'Spec 1', 
      :comment_allow           => true, 
      :comment_require_account => false,
      :comment_moderate        => false, 
      :comment_format          => 'plain'
    )

    Testdata[:section_1].name.should === 'Spec'
    Testdata[:section_2].name.should === 'Spec 1'
  end

  it('Retrieve all sections') do
    sections = plugin(:sections)

    sections.count.should   === 2
    sections[0][:name].should === 'Spec'
    sections[1][:name].should === 'Spec 1'
  end

  it('Retrieve a single section') do
    section = plugin(:sections, :section => 'spec')

    section[:name].should           === 'Spec'
    section[:comment_allow].should  === true
    section[:comment_format].should === 'plain'
  end

  it('Retrieve a single section by it\'s ID') do
    section = plugin(
      :sections, :section => Testdata[:section_1].id
    )

    section[:name].should           === 'Spec'
    section[:comment_allow].should  === true
    section[:comment_format].should === 'plain'
  end

  it('Limit the amount of sections') do
    sections = plugin(:sections, :limit => 1)

    sections.count.should     === 1
    sections[0][:name].should === 'Spec'
  end

  it('Limit the amount of sections and set an offset') do
    sections = plugin(:sections, :limit => 1, :offset => 1)

    sections.count.should     === 1
    sections[0][:name].should === 'Spec 1'
  end

  it('Delete the test data') do
    Testdata[:section_1].destroy
    Testdata[:section_2].destroy

    Section[:name => 'Spec'].should   === nil
    Section[:name => 'Spec 1'].should === nil
  end

end
