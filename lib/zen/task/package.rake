namespace :package do
  desc 'Lists all installed packages'
  task :list do
    require File.expand_path('../../../zen', __FILE__)

    Zen::Package::REGISTERED.each do |name, pkg|
      if pkg.about.nil? or pkg.about.empty?
        puts "* #{name}"
      else
        puts "* #{name}\n  #{pkg.about}"
      end
    end
  end

  desc 'Migrates a specific package'
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
    if !Zen::Package::REGISTERED[name]
      abort "The package name \"#{name}\" is invalid."
    end

    package = Zen::Package::REGISTERED[name]

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

    Zen::Migrator.run(package.name, dir, table, version)
  end
end
