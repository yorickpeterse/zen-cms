Ramaze::HelpersHelper.options.paths.push(__DIR__('users'))

require __DIR__('users/model/user')
require __DIR__('users/model/user_group')
require __DIR__('users/model/access_rule')
require __DIR__('users/controller/users')
require __DIR__('users/controller/user_groups')
require __DIR__('users/controller/access_rules')

Zen::Language.options.paths.push(__DIR__('users'))
Zen::Language.load('users')
Zen::Language.load('user_groups')
Zen::Language.load('access_rules')

# The trait for the User helper has to be specified in the constructor as
# our user model is loaded after this class is loaded (but before it's initialized)
Zen::Controller::BaseController.trait(:user_model => Users::Model::User)

Zen::Package.add do |p|
  p.name          = 'users'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = "Module for managing users along with handling authentication and 
authorization."
  
  p.directory     = __DIR__('users')
  p.migration_dir = __DIR__('../migrations')
  
  p.menu = [{
    :title    => lang('users.titles.index'),
    :url      => 'admin/users',
    :children => [
      {:title => lang('user_groups.titles.index') , :url => 'admin/user-groups' },
      {:title => lang('access_rules.titles.index'), :url => 'admin/access-rules'}
    ]
  }]

  p.controllers = {
    lang('users.titles.index')        => Users::Controller::Users, 
    lang('user_groups.titles.index')  => Users::Controller::UserGroups, 
    lang('access_rules.titles.index') => Users::Controller::AccessRules
  }
end
