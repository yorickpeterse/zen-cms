desc 'Installs all the required gems'
task :setup do
  sh('rvm gemset import .gems')
end
