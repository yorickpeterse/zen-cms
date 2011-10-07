namespace :package do
  desc 'Lists all installed packages'
  task :list do
    require File.expand_path('../../../zen', __FILE__)

    Zen::Package::Registered.each do |name, pkg|
      if pkg.about.nil? or pkg.about.empty?
        puts "* #{name}"
      else
        puts "* #{name}\n  #{pkg.about}"
      end
    end
  end

  desc 'Migrates a package to a certain version'
  task :migrate, :name, :version do |task, args|
    require File.expand_path('../../../zen', __FILE__)

    if !args[:name]
      abort "You need to specify the name of a package to migrate"
    end

    name = args[:name].to_sym

    if !args[:version]
      version = nil
    else
      version = args[:version].to_i
    end

    # Validate the package name
    if !Zen::Package::Registered[name]
      abort "The package name \"#{name}\" is invalid."
    end

    package = Zen::Package::Registered[name]

    # Get the migrations directory
    if package.respond_to?(:migrations) and !package.migrations.nil?
      dir = package.migrations
    else
      abort 'The specified package has no migrations directory set'
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
