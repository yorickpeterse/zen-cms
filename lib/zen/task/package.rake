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
#{name}
--------------------
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
      version = args[:version].to_i
    end

    # Validate the package name
    if !Zen::Package::Registered[args[:name].to_sym]
      abort "The package name \"#{args[:name]}\" is invalid."
    end

    package = Zen::Package::Registered[args[:name].to_sym]

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

    table = 'migrations_package_' + package.name.to_s

    Ramaze::Log.info('Migrating package...')

    # Run all migrations
    Zen.database.transaction do
      Sequel::Migrator.run(
        Zen.database, dir, :table => table, :target => version
      )
    end
  end

end
