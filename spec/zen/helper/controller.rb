require File.expand_path('../../../helper', __FILE__)
require File.join(Zen::FIXTURES, 'helper', 'controller')

describe 'Ramaze::Helper::Controller' do
  behaves_like :capybara
  extend Ramaze::Helper::Controller

  it 'Set the title of a controller method' do
    visit('/admin/spec-controller-helper')

    page.body.include?('index method').should == true
    page.find('title').text.should            == lang('categories.titles.index')
  end

  it 'Protect a controller method against CSRF attacks' do
    visit('/admin/spec-controller-helper/csrf')

    page.body.include?('csrf method').should                   == false
    page.body.include?(lang('zen_general.errors.csrf')).should == true
  end

  it 'Generate a link to manage sub data' do
    manage_link('a', 'b').should == '<a href="a" class="icon pages">b</a>'
  end

  it 'Generate a link to edit data' do
    edit_link('a', 'b').should == '<a href="a" class="icon edit">b</a>'
  end

  it 'Generate a button to create new data' do
    new_button('a', 'b').should == '<a href="a" class="button">b</a>'
  end

  it 'Generate a button to delete data' do
    delete_button('a').should == '<input type="submit" value="a" ' \
      'class="button danger" />'
  end

  it 'Generate a short name for various browsers' do
    chrome = browser_name(
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/535.7 ' \
        '(KHTML, like Gecko) Chrome/16.0.912.63 Safari/535.7'
    )

    firefox = browser_name(
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:8.0.1) ' \
        'Gecko/20100101 Firefox/8.0.1'
    )

    ie = browser_name(
      'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0;'
    )

    safari  = browser_name(
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.51.22 ' \
        '(KHTML, like Gecko) Version/5.1.1 Safari/534.51.22'
    )

    chrome.should  == 'chrome'
    firefox.should == 'firefox'
    ie.should      == 'internet_explorer'
    safari.should  == 'safari'
  end
end
