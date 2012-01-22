Dashboard::Widget.add do |w|
  w.name  = :spec
  w.title = 'Spec'
  w.data  = lambda { 'spec widget' }
end
