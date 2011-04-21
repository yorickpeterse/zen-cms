require __DIR__('users/model/user')
require __DIR__('users/model/user_group')
require __DIR__('users/model/access_rule')
require __DIR__('users/controller/users')
require __DIR__('users/controller/user_groups')
require __DIR__('users/controller/access_rules')

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
    :title    => "Users",
    :url      => "admin/users",
    :children => [
      {:title => "User Groups" , :url => "admin/user-groups" },
      {:title => "Access Rules", :url => "admin/access-rules"}
    ]
  }]
end
