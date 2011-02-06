require File.expand_path('../../spec', __FILE__)

class SpecGeneral < Liquid::Block
  include Zen::Liquid::General
  
  def initialize tag_name, arguments, html
    super
    
    @arguments = parse_key_values(arguments)
  end
  
  def render context
    result = []
    
    @arguments.each do |k, v|
      context[k.to_s] = v
      
      result << render_all(@nodelist, context)
    end
    
    return result
  end
end

Liquid::Template.register_tag('specblock', SpecGeneral)

describe Zen::Liquid::General do
  it 'Parse a template + variable' do
    template = Liquid::Template.parse 'hello {{name}}'
    template.render('name' => 'yorick').should.equal 'hello yorick'
  end
  
  it 'Parse a key/value block' do
    template = Liquid::Template.parse '{% specblock name="yorick" %}hello {{name}}{% endspecblock %}'
    template.render.should.equal 'hello yorick'
  end
  
  it 'Parse a key/value block using single quotes' do
    template = Liquid::Template.parse '{% specblock name=\'yorick\' %}hello {{name}}{% endspecblock %}'
    template.render.should.equal 'hello yorick'
  end
end