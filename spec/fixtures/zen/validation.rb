class ValidationObject
  include ::Zen::Validation

  attr_accessor :name
  attr_accessor :file

  def presence
    validates_presence(:name)
  end

  def length
    validates_length(:name, :min => 3, :max => 5)
  end

  def format
    validates_format(:name, /[a-z]+/)
  end

  def exists
    validates_filepath(:file)
  end
end
