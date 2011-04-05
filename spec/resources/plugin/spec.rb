class SpecPlugin
  def initialize(transformation, text)
    @transformation, @text = transformation, text
  end

  def call
    return @text.send(@transformation)
  end
end
