Zen::Package.add do |p|
  p.name       = :comments
  p.title      = 'comments.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://yorickpeterse.com/'
  p.about      = 'comments.description'
  p.root       = __DIR__('comments')
  p.migrations = __DIR__('../migrations')

  p.menu(
    'comments.titles.index',
    '/admin/comments',
    :permission => :show_comment
  )

  p.permission :show_comment  , 'comments.permissions.show'
  p.permission :edit_comment  , 'comments.permissions.edit'
  p.permission :delete_comment, 'comments.permissions.delete'
end

Zen::Language.load('comments')

require __DIR__('comments/model/comment_status')
require __DIR__('comments/model/comment')
require __DIR__('comments/controller/comments')
require __DIR__('comments/controller/comments_form')
require __DIR__('comments/plugin/comments')
require __DIR__('comments/plugin/anti_spam')

Zen::Plugin.add do |p|
  p.name    = 'comments'
  p.author  = 'Yorick Peterse'
  p.url     = 'http://yorickpeterse.com/'
  p.about   = 'comments.plugin.comments'
  p.plugin  = Comments::Plugin::Comments
end

Zen::Plugin.add do |p|
  p.name    = 'anti_spam'
  p.author  = 'Yorick Peterse'
  p.url     = 'http://yorickpeterse.com/'
  p.about   = 'comments.plugins.anti_spam'
  p.plugin  = Comments::Plugin::AntiSpam
end

plugin(:settings, :register) do |setting|
  setting.title       = 'comments.labels.anti_spam_system'
  setting.description = 'comments.placeholders.anti_spam_system'
  setting.name        = 'anti_spam_system'
  setting.group       = 'security'
  setting.type        = 'select'
  setting.default     = 'defensio'
  setting.values      = {'defensio' => lang('comments.labels.defensio')}
end

plugin(:settings, :register) do |setting|
  setting.title       = 'comments.labels.defensio_key'
  setting.description = 'comments.placeholders.defensio_key'
  setting.name        = 'defensio_key'
  setting.group       = 'security'
  setting.type        = 'textbox'
end
