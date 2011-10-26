require File.expand_path('../../../helper', __FILE__)
require __DIR__('../../fixtures/zen/helper/locale')

describe('Ramaze::Helper::Locale') do
  behaves_like :capybara
  extend       Ramaze::Helper::Locale

  it('Get the date format') do
    visit('/admin/spec-locale-helper')

    format = get_setting(:date_format).value

    date_format.should == format

    # Get the date format from the session
    page.body.include?(format).should == true
  end

  it('Format a date') do
    format = get_setting(:date_format).value
    date   = Time.new

    format_date(date).should == date.strftime(format)
  end
end
