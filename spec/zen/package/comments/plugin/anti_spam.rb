require File.expand_path('../../../../../helper', __FILE__)

# If any system fails at this comment it's run buy a bunch of idiots.
spam_comment = 'Hello, you can buy viagra here <a href="http://buyviagra.com/">
Buy Viagra</a>'

describe("Comments::Plugin::AntiSpam") do
  behaves_like :capybara

  it('Validate a spam comment using Defensio') do
    yaml_response = <<-YAML.strip
    defensio-result:
      api-version: 2.0
      status: success
      message:
      signature: 1234abc
      allow: false
      classification: spam
      spaminess: 0.9
      profanity-match: false
    YAML

    stub_request(
      :post,
      'http://api.defensio.com/2.0/users/test/documents.yaml'
    ).to_return(:body => yaml_response)

    plugin(:settings, :get, :defensio_key).value = 'test'
    plugin(:anti_spam, :defensio, nil, nil, nil, spam_comment).should === true

    WebMock.reset!
  end

end
