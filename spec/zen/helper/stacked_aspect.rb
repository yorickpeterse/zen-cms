require File.expand_path('../../../helper', __FILE__)
require __DIR__('../../fixtures/zen/helper/stacked_aspect')

describe('Ramaze::Helper::StackedAspect') do
  behaves_like :capybara

  it('Stack stacked_before_all calls') do
    visit('/spec-stacked-aspect-helper')

    page.find('p:first-child').text.should == '2'
  end

  it('Stack stacked_before calls') do
    visit('/spec-stacked-aspect-helper/a')

    page.find('p:first-child').text.should == '4'
  end
end
