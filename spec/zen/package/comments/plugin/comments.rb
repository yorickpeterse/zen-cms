require File.expand_path('../../../../../helper', __FILE__)
require 'rdiscount'

TestData = {}

describe("Comments::Plugin::Comments") do
  include Sections::Model
  include Comments::Model
  include Users::Model

  it("Create the test data") do
    user = User[:email => 'spec@domain.tld']

    TestData[:section] = Section.new(
      :name => 'Spec', :comment_allow => true, :comment_require_account => false, 
      :comment_moderate => false, :comment_format => 'markdown'
    ).save

    TestData[:entry] = SectionEntry.new(
      :title   => 'Spec', :status => 'published', :section_id => TestData[:section].id,
      :user_id => user.id
    ).save

    TestData[:comment_1] = Comment.new(
      :user_id => user.id, :comment => 'Spec comment', :status => 'open', 
      :section_entry_id => TestData[:entry].id, :email => user.email
    ).save

    TestData[:comment_2] = Comment.new(
      :user_id => user.id, :comment => 'Spec comment 1', :status => 'open', 
      :section_entry_id => TestData[:entry].id, :email => user.email
    ).save
  end

  it("Retrieve all comments for an ID") do
    comments = Zen::Plugin.call('com.zen.plugin.comments', :entry => TestData[:entry].slug)
    
    comments.count.should                                 === 2
    comments[0].comment.include?('Spec comment').should   === true
    comments[1].comment.include?('Spec comment 1').should === true 
  end

  it("Retrieve all comments for a slug") do
    comments = Zen::Plugin.call('com.zen.plugin.comments', :entry => TestData[:entry].id)
    
    comments.count.should                                 === 2
    comments[0].comment.include?('Spec comment').should   === true
    comments[1].comment.include?('Spec comment 1').should === true 
  end

  it("Retrieve a single comment") do
    comments = Zen::Plugin.call(
      'com.zen.plugin.comments', :entry => TestData[:entry].id, :limit => 1
    )

    comments.count.should                               === 1
    comments[0].comment.include?('Spec comment').should === true
  end

  it("Retrieve a single comment with an offset") do
    comments = Zen::Plugin.call(
      'com.zen.plugin.comments', :entry => TestData[:entry].id, :limit => 1, :offset => 1
    )

    comments.count.should                                 === 1
    comments[0].comment.include?('Spec comment 1').should === true
  end

  it("Remove the test data") do
    TestData[:comment_2].delete
    TestData[:comment_1].delete
    TestData[:entry].delete
    TestData[:section].delete
  end

end
