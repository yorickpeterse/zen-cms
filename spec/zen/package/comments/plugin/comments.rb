require File.expand_path('../../../../../helper', __FILE__)
require 'rdiscount'

describe("Comments::Plugin::Comments") do
  user      = Users::Model::User[:email => 'spec@domain.tld']
  status_id = Comments::Model::CommentStatus[:name => 'open'].id
  @section  = Sections::Model::Section.create(
    :name                     => 'Spec',
    :comment_allow            => true,
    :comment_require_account  => false,
    :comment_moderate         => false,
    :comment_format           => 'markdown'
  )

  @entry = Sections::Model::SectionEntry.create(
    :title      => 'Spec',
    :section_id => @section.id,
    :user_id    => user.id
  )

  @comment_1 = Comments::Model::Comment.create(
    :user_id           => user.id,
    :comment           => 'Spec comment',
    :comment_status_id => status_id,
    :section_entry_id  => @entry.id,
    :email             => user.email
  )

  @comment_2 = Comments::Model::Comment.create(
    :user_id           => user.id,
    :comment           => 'Spec comment 1',
    :comment_status_id => status_id,
    :section_entry_id  => @entry.id,
    :email             => user.email
  )

  it("Retrieve all comments for an ID") do
    comments = plugin(:comments, :entry => @entry.slug)

    comments.count.should                                   === 2
    comments[0].class.should                                ==  Hash
    comments[0][:comment].include?('Spec comment').should   === true
    comments[1][:comment].include?('Spec comment 1').should === true
    comments[1][:user][:email].should  === 'spec@domain.tld'
    comments[1][:user][:name].should   === 'Spec'
  end

  it("Retrieve all comments for a slug") do
    comments = plugin(:comments, :entry => @entry.id)

    comments.count.should                                   === 2
    comments[0][:comment].include?('Spec comment').should   === true
    comments[1][:comment].include?('Spec comment 1').should === true
  end

  it("Retrieve all comments and check the markup") do
    comments = plugin(:comments, :entry => @entry.id)

    comments.count.should              === 2
    comments[0][:comment].strip.should === '<p>Spec comment</p>'
    comments[1][:comment].strip.should === '<p>Spec comment 1</p>'
  end

  it("Retrieve a single comment") do
    comments = plugin(
      :comments, :entry => @entry.id, :limit => 1
    )

    comments.count.should                                 === 1
    comments[0][:comment].include?('Spec comment').should === true
  end

  it("Retrieve a single comment with an offset") do
    comments = plugin(
      :comments, :entry => @entry.id, :limit => 1, :offset => 1
    )

    comments.count.should                                   === 1
    comments[0][:comment].include?('Spec comment 1').should === true
  end

  @comment_2.destroy
  @comment_1.destroy
  @entry.destroy
  @section.destroy
end
