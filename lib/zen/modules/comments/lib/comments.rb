
# Load all our classes
require __DIR__ 'comments/model/comment.rb'
require __DIR__ 'comments/controller/comments'
require __DIR__ 'comments/controller/comments_form'
require __DIR__ 'comments/liquid/comments'
require __DIR__ 'comments/liquid/comment_form'

Liquid::Template.register_tag('comments'    , Comments::Liquid::Comments)
Liquid::Template.register_tag('comment_form', Comments::Liquid::CommentForm)

Zen::Extension.add do |ext|
  ext.name        = 'Comments'
  ext.author      = 'Yorick Peterse'
  ext.url         = 'http://yorickpeterse.com/'
  ext.version     = 1.0
  ext.about       = "Allow users to post comments on any given section entry (as long as the section allows it)."
  ext.identifier  = 'com.yorickpeterse.comments'
  ext.directory   = __DIR__('comments')
  
  ext.menu = [{
    :title => "Comments",
    :url   => "admin/comments"
  }]
end
