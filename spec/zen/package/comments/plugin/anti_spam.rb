require File.expand_path('../../../../../helper', __FILE__)

# If any system fails at this comment it's run buy a bunch of idiots.
spam_comment = 'Hello, you can buy viagra here <a href="http://buyviagra.com/">
Buy Viagra</a>'

describe("Comments::Plugin::AntiSpam") do
  behaves_like :capybara

  it('Validate a spam comment using Defensio') do
    plugin(:settings, :get, :defensio_key).value = 'test'
    plugin(:anti_spam, :defensio, nil, nil, nil, spam_comment).should === true
  end

end
