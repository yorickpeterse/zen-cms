# Task group for managing plugins.
namespace :plugin do

  desc 'Lists all installed plugins'
  task :list do
    Zen::Plugin::Registered.each do |name, pkg|
      message = <<-MSG
#{name}
--------------------
#{pkg.about}

MSG

      puts message
    end
  end

end
