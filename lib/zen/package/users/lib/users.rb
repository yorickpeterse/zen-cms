
require __DIR__('users/model/user')
require __DIR__('users/model/user_group')
require __DIR__('users/model/access_rule')

require __DIR__('users/controller/users')
require __DIR__('users/controller/user_groups')
require __DIR__('users/controller/access_rules')

require __DIR__('users/liquid/users')
require __DIR__('users/liquid/user')

Liquid::Template.register_tag('users', Users::Liquid::Users)
Liquid::Template.register_tag('user' , Users::Liquid::User)

# The trait for the User helper has to be specified in the constructor as
# our user model is loaded after this class is loaded (but before it's initialized)
Zen::Controllers::BaseController.trait(:user_model => Users::Models::User)

Zen::Package.add do |p|
  p.name          = 'Users'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = "Module for managing users along with handling authentication and authorization."
  
  p.identifier    = 'com.zen.users'
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
