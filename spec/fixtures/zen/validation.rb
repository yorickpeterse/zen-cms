class ValidationObject
  include ::Zen::Validation

  attr_accessor :name

  def presence; validates_presence(:name)                    ; end
  def length  ; validates_length(:name, :min => 3, :max => 5); end
  def format  ; validates_format(:name, /[a-z]+/)            ; end
end
