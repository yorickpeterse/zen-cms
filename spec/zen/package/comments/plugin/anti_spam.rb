require File.expand_path('../../../../../helper', __FILE__)

# If any system fails at this comment it's run buy a bunch of idiots.
spam_comment = 'Hello, you can buy viagra here <a href="http://buyviagra.com/">Buy Viagra</a>'

describe("Comments::Plugin::AntiSpam") do

  it('Validate a spam comment using Defensio') do
    status, spam = plugin(:anti_spam, :defensio, nil, nil, nil, spam_comment)

    status.should >=  0.85
    spam.should   === true
  end

end
