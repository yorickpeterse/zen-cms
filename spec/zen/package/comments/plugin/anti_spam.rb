require File.expand_path('../../../../../helper', __FILE__)

describe("Comments::Plugin::AntiSpam") do
  behaves_like :capybara

  spam_comment = 'Hello, you can buy viagra here ' \
    '<a href="http://buyviagra.com/">Buy Viagra</a>'

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

  it('Try to use an invalid engine') do
    should.raise?(Zen::PluginError) do
      plugin(:anti_spam, :foobar, nil, nil, nil, spam_comment)
    end
  end

  it('Validate a spam comment using Defensio') do
    plugin(:settings, :get, :defensio_key).value = 'test'
    plugin(:anti_spam, :defensio, nil, nil, nil, spam_comment).should === true
  end

  it('Validate a comment using Defensio without an API key') do
    plugin(:settings, :get, :defensio_key).value = nil

    should.raise?(Zen::PluginError) do
      plugin(:anti_spam, :defensio, nil, nil, nil, spam_comment)
    end

    plugin(:settings, :get, :defensio_key).value = 'test'
  end

  it('Load an engine\'s Gem that does not exist') do
    Comments::Plugin::AntiSpam::Registered[:defensio] = 'test'

    should.raise?(LoadError) do
      plugin(:anti_spam, :defensio, nil, nil, nil, spam_comment)
    end

    Comments::Plugin::AntiSpam::Registered[:defensio] = 'defensio'
  end

  WebMock.reset!
end # describe
