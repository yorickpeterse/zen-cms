
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

Zen::Package.add do |p|
  p.type        = 'extension'
  p.name        = 'Users'
  p.author      = 'Yorick Peterse'
  p.url         = 'http://yorickpeterse.com/'
  p.version     = '1.0'
  p.about       = "Module for managing users along with handling authentication and authorization."
  
  p.identifier  = 'com.zen.users'
  p.directory   = __DIR__('users')
  
  p.menu = [{
    :title    => "Users",
    :url      => "admin/users",
    :children => [
      {:title => "User Groups" , :url => "admin/user_groups"},
      {:title => "Access Rules", :url => "admin/access_rules"}
    ]
  }]
end
