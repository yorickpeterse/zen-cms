
# Load all our classes
require __DIR__ 'comments/model/comment.rb'
require __DIR__ 'comments/controller/comments'
require __DIR__ 'comments/controller/comments_form'
require __DIR__ 'comments/liquid/comments'
require __DIR__ 'comments/liquid/comment_form'

Liquid::Template.register_tag('comments'    , Comments::Liquid::Comments)
Liquid::Template.register_tag('comment_form', Comments::Liquid::CommentForm)

Zen::Package.add do |p|
  p.name          = 'Comments'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = "Allow users to post comments on any given section entry (as long as the section allows it)."
  p.identifier    = 'com.zen.comments'
  p.directory     = __DIR__('comments')
  p.migration_dir = __DIR__('../migrations')
  
  p.menu = [{
    :title => "Comments",
    :url   => "admin/comments"
  }]
end
