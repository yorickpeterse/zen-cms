require File.expand_path('../../../helper', __FILE__)

describe 'Ramaze::Helper::Common' do
  extend Ramaze::Helper::Common

  it('Create an anchor tag') do
    tag = Nokogiri::HTML.fragment(anchor_to('text', 'url')).children[0]

    tag.attribute('href').value.should === '/url'
    tag.text.should                    === 'text'
  end

  it('Create an anchor tag with a title') do
    tag = Nokogiri::HTML.fragment(anchor_to('text', 'url', :title => 'title')) \
      .children[0]

    tag.attribute('title').value.should === 'title'
    tag.attribute('href').value.should  === '/url'
  end

  it('Create an anchor tag with two attributes') do
    tag = Nokogiri::HTML.fragment(
      anchor_to('text', 'url', :title => 'title', :'data-test' => 'data-test')
    ).children[0]

    tag.attribute('title').value.should     === 'title'
    tag.attribute('data-test').value.should === 'data-test'
  end

  it('Create an anchor tag with a query string') do
    tag = Nokogiri::HTML.fragment(
      anchor_to(
        'text', 
        {:href => '/url', :a => 'ruby', :b => 'python'},
        {:class => 'my_class'}
      )
    ).children[0]

    tag.attribute('href').value.should  === '/url?a=ruby&b=python'
    tag.attribute('class').value.should === 'my_class'
  end

end
