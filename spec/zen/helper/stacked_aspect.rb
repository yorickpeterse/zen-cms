require File.expand_path('../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'helper', 'stacked_aspect')

describe 'Ramaze::Helper::StackedAspect' do
  behaves_like :capybara

  before do
    SpecStackedAspect::NUMBERS.each do |k, v|
      SpecStackedAspect::NUMBERS[k] = 0
    end
  end

  it 'Ramaze::Helper::StackedAspect.stacked_before_all' do
    visit('/spec-stacked-aspect/before_all')

    page.has_content?('15').should                 == true
    SpecStackedAspect::NUMBERS[:before_all].should == 15
  end

  it 'Ramaze::Helper::StackedAspect.stacked_before' do
    visit('/spec-stacked-aspect/before')

    page.has_content?('4').should              == true
    SpecStackedAspect::NUMBERS[:before].should == 4
  end

  it 'Ramaze::Helper::StackedAspect.stacked_after_all' do
    visit('/spec-stacked-aspect/before_all')

    page.has_content?('15').should                == true
    SpecStackedAspect::NUMBERS[:after_all].should == 15
  end

  it 'Ramaze::Helper::StackedAspect.stacked_after' do
    visit('/spec-stacked-aspect/after')

    page.has_content?('0').should             == true
    SpecStackedAspect::NUMBERS[:after].should == 4
  end
end
