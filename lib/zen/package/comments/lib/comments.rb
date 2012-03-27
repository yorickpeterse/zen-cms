Zen::Package.add do |p|
  p.name       = :comments
  p.title      = 'comments.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://zen-cms.com/'
  p.about      = 'comments.description'
  p.root       = __DIR__('comments')
  p.migrations = __DIR__('../migrations')

  p.menu 'comments.titles.index',
    '/admin/comments',
    :permission => :show_comment

  p.permission :show_comment  , 'comments.permissions.show'
  p.permission :edit_comment  , 'comments.permissions.edit'
  p.permission :delete_comment, 'comments.permissions.delete'
end

require __DIR__('comments/model/comment_status')
require __DIR__('comments/model/comment')
require __DIR__('comments/controller/comments')
require __DIR__('comments/controller/comments_form')
require __DIR__('comments/anti_spam')

Zen::Controller::FrontendController.helper(:comment_frontend)

Settings::Setting.add do |setting|
  setting.title       = 'comments.labels.anti_spam_system'
  setting.description = 'comments.descriptions.anti_spam_system'
  setting.name        = 'anti_spam_system'
  setting.group       = 'security'
  setting.type        = 'select'
  setting.default     = 'defensio'
  setting.values      = lambda do
    regged = {}

    Comments::AntiSpam::REGISTERED.each do |name, translation|
      regged[name] = lang(translation)
    end

    return regged
  end
end

Settings::Setting.add do |setting|
  setting.title       = 'comments.labels.defensio_key'
  setting.description = 'comments.descriptions.defensio_key'
  setting.name        = 'defensio_key'
  setting.group       = 'security'
  setting.type        = 'textbox'
end

Zen::Event.listen :post_start do
  Zen::Language.load('comments')
end
