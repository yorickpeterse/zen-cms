##
# Task group for managing themes.
#
# @author Yorick Peterse
# @since  0.2.5
#
namespace :theme do

  desc 'Lists all installed themes'
  task :list do
    Zen::Theme::Registered.each do |name, pkg|
      message = <<-MSG
#{name}
--------------------
#{pkg.about}

MSG

      puts message
    end
  end

  desc 'Migrates a theme to the given version'
  task :migrate, :name, :version do |task, args|
    if !args[:name]
      abort 'You need to specify the name of the theme.'
    end

    if !args[:version]
      version = nil
      puts 'No version specified, choosing the most recent version...'
    else
      version = args[:version].to_i
    end

    name = args[:name].to_sym

    if !Zen::Theme::Registered[name]
      abort 'The specified theme does not exist.'
    end

    theme = Zen::Theme::Registered[name]
    table = 'migrations_theme_' + theme.name.to_s

    # Fetch the migrations directory
    if theme.respond_to?(:migration_dir) and !theme.migration_dir.nil?
      dir = theme.migration_dir
    else
      abort 'The specified theme does not have a migrations directory.'
    end

    if !File.directory?(dir)
      abort 'The theme\'s migration directory doesn\'t exist.'
    end

    # Time to migrate the theme
    Ramaze::Log.info('Migrating package...')

    Zen.database.transaction do
      Sequel::Migrator.run(
        Zen.database, dir, :table => table, :target => version
      )
    end
  end

end
