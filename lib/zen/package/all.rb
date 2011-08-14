# Loads all core packages that ship with Zen. Note that it's important to load
# these packages in the correct order as otherwise migrations that create
# foreign keys might not work.
require __DIR__('users/lib/users')
require __DIR__('settings/lib/settings')
require __DIR__('sections/lib/sections')
require __DIR__('comments/lib/comments')
require __DIR__('categories/lib/categories')
require __DIR__('custom_fields/lib/custom_fields')
require __DIR__('menus/lib/menus')
