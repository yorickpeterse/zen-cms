require File.expand_path('../../../../../helper', __FILE__)
require 'rdiscount'

describe("Comments::Plugin::Comments") do
  extend Sections::Model
  extend Comments::Model
  extend Users::Model

  it("Create the test data") do
    user      = User[:email => 'spec@domain.tld']
    status_id = CommentStatus[:name => 'open'].id

    Testdata[:section] = Section.create(
      :name                     => 'Spec', 
      :comment_allow            => true, 
      :comment_require_account  => false, 
      :comment_moderate         => false, 
      :comment_format           => 'markdown'
    )

    Testdata[:entry] = SectionEntry.create(
      :title      => 'Spec', 
      :status     => 'published', 
      :section_id => Testdata[:section].id,
      :user_id    => user.id
    )

    Testdata[:comment_1] = Comment.create(
      :user_id          => user.id, 
      :comment          => 'Spec comment', 
      :status           => status_id, 
      :section_entry_id => Testdata[:entry].id, 
      :email            => user.email
    )

    Testdata[:comment_2] = Comment.create(
      :user_id          => user.id, 
      :comment          => 'Spec comment 1', 
      :status           => status_id, 
      :section_entry_id => Testdata[:entry].id, 
      :email            => user.email
    )

    Testdata[:section].name.should      === 'Spec'
    Testdata[:entry].title.should       === 'Spec'
    Testdata[:comment_1].comment.should === 'Spec comment'
    Testdata[:comment_2].comment.should === 'Spec comment 1'
  end

  it("Retrieve all comments for an ID") do
    comments = plugin(:comments, :entry => Testdata[:entry].slug)
    
    comments.count.should                                   === 2
    comments[0].class.should                                ==  Hash
    comments[0][:comment].include?('Spec comment').should   === true
    comments[1][:comment].include?('Spec comment 1').should === true
    comments[1][:user][:email].should  === 'spec@domain.tld'
    comments[1][:user][:name].should   === 'Spec'
  end

  it("Retrieve all comments for a slug") do
    comments = plugin(:comments, :entry => Testdata[:entry].id)
    
    comments.count.should                                   === 2
    comments[0][:comment].include?('Spec comment').should   === true
    comments[1][:comment].include?('Spec comment 1').should === true 
  end

  it("Retrieve all comments and check the markup") do
    comments = plugin(:comments, :entry => Testdata[:entry].id)
    
    comments.count.should              === 2
    comments[0][:comment].strip.should === '<p>Spec comment</p>'
    comments[1][:comment].strip.should === '<p>Spec comment 1</p>' 
  end

  it("Retrieve a single comment") do
    comments = plugin(
      :comments, :entry => Testdata[:entry].id, :limit => 1
    )

    comments.count.should                                 === 1
    comments[0][:comment].include?('Spec comment').should === true
  end

  it("Retrieve a single comment with an offset") do
    comments = plugin(
      :comments, :entry => Testdata[:entry].id, :limit => 1, :offset => 1
    )

    comments.count.should                                   === 1
    comments[0][:comment].include?('Spec comment 1').should === true
  end

  it("Remove the test data") do
    Testdata[:comment_2].destroy
    Testdata[:comment_1].destroy
    Testdata[:entry].destroy
    Testdata[:section].destroy

    Comment[:comment => 'Spec comment'].should   === nil
    Comment[:comment => 'Spec comment 1'].should === nil
    Section[:name => 'Spec'].should              === nil
    SectionEntry[:title => 'Spec'].should        === nil
  end

end
