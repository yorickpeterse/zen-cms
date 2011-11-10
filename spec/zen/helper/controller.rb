require File.expand_path('../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'helper', 'controller')

describe('Ramaze::Helper::Controller') do
  behaves_like :capybara

  should('set an action title') do
    visit('/admin/spec-controller-helper')

    page.body.include?('index method').should == true
    page.find('title').text.should            == lang('categories.titles.index')
  end

  should('protect a method against a CSRF attack') do
    visit('/admin/spec-controller-helper/csrf')

    page.body.include?('csrf method').should                   == false
    page.status_code.should                                    == 403
    page.body.include?(lang('zen_general.errors.csrf')).should == true
  end
end
