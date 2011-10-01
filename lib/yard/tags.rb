require 'yard'

# The @map tag is used to indicate at what URI a controller is mapped.
YARD::Tags::Library.define_tag('Mapped URI', :map)

# The @permission tag can be used to define the required permissions.
YARD::Tags::Library.define_tag('Required permissions', :permission)

# The @event tag is a tag that indicates all the available events in a block of
# code.
YARD::Tags::Library.define_tag('Available Events', :event)

YARD::Tags::Library.visible_tags += [:permission, :map, :event]
