require 'yard'

# The @map tag is used to indicate at what URI a controller is mapped.
YARD::Tags::Library.define_tag('Mapped URI', :map)

# The @permission tag can be used to define the required permissions.
YARD::Tags::Library.define_tag('Required permissions', :permission)

# The @request tag can be used to specify a list of valid HTTP requests for a
# method. These requests should be specified in the format of METHOD URL.
YARD::Tags::Library.define_tag('Valid HTTP requests' , :request)

# The @event tag is a tag that indicates all the available events in a block of
# code.
YARD::Tags::Library.define_tag('Available Events', :event)

YARD::Tags::Library.visible_tags += [:permission, :request, :map, :event]
