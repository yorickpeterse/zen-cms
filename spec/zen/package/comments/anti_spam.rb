require File.expand_path('../../../../helper', __FILE__)

describe 'Comments::AntiSpam' do
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

  it 'Fail to use an invalid engine' do
    should.raise?(ArgumentError) do
      Comments::AntiSpam.validate(:foobar, nil, nil, nil, spam_comment)
    end
  end

  it 'Validate a spam comment using Defensio' do
    get_setting(:defensio_key).value = 'test'

    Comments::AntiSpam.validate(:defensio, nil, nil, nil, spam_comment) \
      .should == true
  end

  it 'Fail to validate using defensio without an API key' do
    get_setting(:defensio_key).value = nil

    should.raise? do
      Comments::AntiSpam.validate(:defensio, nil, nil, nil, spam_comment)
    end

    get_setting(:defensio_key).value = 'test'
  end

  WebMock.reset!
end
