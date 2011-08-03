Ramaze::HelpersHelper.options.paths.push(__DIR__('comments'))

require __DIR__('comments/model/comment_status')
require __DIR__('comments/model/comment')
require __DIR__('comments/controller/comments')
require __DIR__('comments/controller/comments_form')
require __DIR__('comments/plugin/comments')
require __DIR__('comments/plugin/anti_spam')

Zen::Language.options.paths.push(__DIR__('comments'))
Zen::Language.load('comments')

Zen::Package.add do |p|
  p.name          = 'comments'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = "Allow users to post comments on any given section entry (as long as
the section allows it)."

  p.directory     = __DIR__('comments')
  p.migration_dir = __DIR__('../migrations')

  p.menu = [{
    :title => lang('comments.titles.index'),
    :url   => "admin/comments"
  }]

  p.controllers = {
    lang('comments.titles.index') => Comments::Controller::Comments
  }
end

Zen::Plugin.add do |p|
  p.name    = 'comments'
  p.author  = 'Yorick Peterse'
  p.url     = 'http://yorickpeterse.com/'
  p.about   = 'Plugin that can be used to retrieve comments.'
  p.plugin  = Comments::Plugin::Comments
end

Zen::Plugin.add do |p|
  p.name    = 'anti_spam'
  p.author  = 'Yorick Peterse'
  p.url     = 'http://yorickpeterse.com/'
  p.about   = 'Plugin used for checking if a comment is spam or ham.'
  p.plugin  = Comments::Plugin::AntiSpam
end

plugin(:settings, :register) do |setting|
  setting.title       = lang('comments.labels.anti_spam_system')
  setting.description = lang('comments.placeholders.anti_spam_system')
  setting.name        = 'anti_spam_system'
  setting.group       = 'security'
  setting.type        = 'select'
  setting.default     = 'defensio'
  setting.values      = {
    'defensio' => lang('comments.labels.defensio')
  }
end

plugin(:settings, :register) do |setting|
  setting.title       = lang('comments.labels.defensio_key')
  setting.description = lang('comments.placeholders.defensio_key')
  setting.name        = 'defensio_key'
  setting.group       = 'security'
  setting.type        = 'textbox'
end
