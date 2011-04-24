##
# Task group for managing plugins.
#
# @author Yorick Peterse
# @since  0.2.5
#
namespace :plugin do

  desc 'Lists all installed plugins'
  task :list do
    Zen::Plugin::Registered.each do |name, pkg|
      message = <<-MSG
--------------------------
Name: #{name}
Author: #{pkg.author}

#{pkg.about}
MSG

      puts message
    end
  end

end
