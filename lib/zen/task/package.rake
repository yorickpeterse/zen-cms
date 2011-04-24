##
# Task group for managing packages.
#
# @author Yorick Peterse
# @since  0.2.5
#
namespace :package do
  
  desc 'Lists all installed packages'
  task :list do
    Zen::Package::Registered.each do |name, pkg|
      message = <<-MSG
--------------------------
Name: #{name}
Author: #{pkg.author}

#{pkg.about}
MSG

      puts message
    end
  end

  desc 'Migrates a package to a certain version'
  task :migrate, :name, :version do |task, args|
    if !args[:name]
      abort "You need to specify the name of a package to migrate"
    end

    if !args[:version]
      version = nil
    else
      version = args[:version]
    end

    # Validate the package name
    if !Zen::Packages::Registered[args[:name].to_sym]
      abort "The package name \"#{args[:name]}\" is invalid."
    end

    package = Zen::Packages::Registered[args[:name].to_sym]

    # Get the migrations directory
    if package.respond_to?(:migration_dir) and !package.migration_dir.nil?
      dir = package.migration_dir
    else
      dir = package.directory + '/../../migrations'
    end

    # Validate the directory
    if !File.directory?(dir)
      abort "The directory #{dir} does not exist."
    end

    table = 'migrations_' + package.name.to_s

    puts "Migrating package..."

    # Run all migrations
    Zen::Database.handle.transaction do
      Sequel.migrator.run(
        Zen::Database.handle, dir, :table => table, :target => version
      )
    end
  end

end
