desc 'Installs all the required gems (requires RVM)'
task :setup do
  sh('rvm gemset import .gems')
end
