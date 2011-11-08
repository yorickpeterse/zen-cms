Zen::Package.add do |p|
  p.name       = :users
  p.title      = 'users.titles.index'
  p.author     = 'Yorick Peterse'
  p.url        = 'http://yorickpeterse.com/'
  p.about      = 'users.description'
  p.root       = __DIR__('users')
  p.migrations = __DIR__('../migrations')

  p.menu(
    'users.titles.index',
    '/admin/users',
    :permission => :show_user
  ) do |sub|
    sub.menu(
      'user_groups.titles.index',
      '/admin/user-groups',
      :permission => :show_user_group
    )
  end

  p.permission :show_user_group  , 'user_groups.permissions.show'
  p.permission :edit_user_group  , 'user_groups.permissions.edit'
  p.permission :new_user_group   , 'user_groups.permissions.new'
  p.permission :delete_user_group, 'user_groups.permissions.delete'

  p.permission :show_user  , 'users.permissions.show'
  p.permission :edit_user  , 'users.permissions.edit'
  p.permission :new_user   , 'users.permissions.new'
  p.permission :delete_user, 'users.permissions.delete'

  p.permission :show_permission, 'permissions.permissions.show'
  p.permission :edit_permission, 'permissions.permissions.edit'
end

Zen::Language.load('users')
Zen::Language.load('user_groups')
Zen::Language.load('permissions')

require __DIR__('users/model/user')
require __DIR__('users/model/user_group')
require __DIR__('users/model/permission')
require __DIR__('users/model/user_status')

# The trait for the User helper has to be specified in the constructor as our
# user model is loaded after this class is loaded (but before it's
# initialized)
Zen::Controller::BaseController.trait(:user_model => Users::Model::User)

Zen::Controller::AdminController.helper(:acl, :access)

# Load the controllers after the helpers have been loaded.
require __DIR__('users/controller/users')
require __DIR__('users/controller/user_groups')
