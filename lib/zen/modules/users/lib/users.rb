
require __DIR__ 'users/model/user'
require __DIR__ 'users/model/user_group'
require __DIR__ 'users/model/access_rule'

require __DIR__ 'users/controller/users'
require __DIR__ 'users/controller/user_groups'
require __DIR__ 'users/controller/access_rules'

require __DIR__ 'users/liquid/users'
require __DIR__ 'users/liquid/user'

Liquid::Template.register_tag('users', Users::Liquid::Users)
Liquid::Template.register_tag('user' , Users::Liquid::User)

Zen::Extension.add do |ext|
  ext.name        = 'Users'
  ext.author      = 'Yorick Peterse'
  ext.url         = 'http://yorickpeterse.com/'
  ext.version     = 1.0
  ext.about       = "Module for managing users along with handling authentication and authorization."
  
  ext.identifier  = 'com.yorickpeterse.users'
  ext.directory   = __DIR__('users')
  
  ext.menu = [{
      :title    => "Users",
      :url      => "admin/users",
      :children => [
        {:title => "User Groups" , :url => "admin/user_groups"},
        {:title => "Access Rules", :url => "admin/access_rules"}
      ]
    }]
end
