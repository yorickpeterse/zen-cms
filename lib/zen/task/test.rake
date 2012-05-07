namespace :test do
  desc 'Run test using default settings'
  task :default do
    Dir.chdir(File.expand_path('../../../../spec', __FILE__))

    sh('rake db:delete')
    sh('rake db:migrate')
    sh('rake db:test_user')

    # Hack to prevent Simplecov from generating code coverage while migrating
    # the database.
    if ENV['_COVERAGE']
      ENV['_COVERAGE'] = nil
      ENV['COVERAGE']  = '1'
    end

    sh('ruby zen/all.rb')
  end

  desc 'Run tests using MySQL'
  task :mysql do
    ENV['DATABASE'] = 'zen_dev'
    ENV['ADAPTER']  = 'mysql2'
    ENV['USERNAME'] = 'zen'

    Rake::Task['test:default'].invoke
  end

  desc 'Run tests using PostgreSQL'
  task :postgres do
    ENV['DATABASE'] = 'zen_dev'
    ENV['ADAPTER']  = 'postgres'
    ENV['USERNAME'] = 'zen'

    Rake::Task['test:default'].invoke
  end

  desc 'Generates code coverage'
  task :coverage do
    ENV['_COVERAGE'] = '1'

    Rake::Task['test:default'].invoke
  end

  # Task that ensures that the various Travis CI tests each use their own
  # database based on the Ruby version.
  desc 'Run tests for Travis CI'
  task :travis do
    suffix = '_' + RUBY_VERSION.gsub('.', '_')

    if ENV['DATABASE']
      if ENV['ADAPTER'] and ENV['ADAPTER'] == 'sqlite'
        split = ENV['DATABASE'].split('.')

        ENV['DATABASE'] = split[0] + suffix + '.' + split[1]
      else
        ENV['DATABASE'] += suffix
      end
    end

    Rake::Task['test:default'].invoke
  end
end
