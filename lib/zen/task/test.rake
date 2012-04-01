namespace :test do
  spec_dir = File.expand_path('../../../../spec', __FILE__)
  command  = 'rake db:delete; rake db:migrate; rake db:test_user; ' \
    'ruby zen/all.rb'

  desc 'Run specifications'
  task :default do
    Dir.chdir(spec_dir)

    sh(command)
  end

  desc 'Runs specifications using MySQL'
  task :mysql do
    Dir.chdir(spec_dir)

    ENV['DATABASE'] = 'zen_dev'
    ENV['ADAPTER']  = 'mysql2'
    ENV['USERNAME'] = 'zen'

    sh(command)
  end

  desc 'Runs specifications using PostgreSQL'
  task :postgres do
    Dir.chdir(spec_dir)

    ENV['DATABASE'] = 'zen_dev'
    ENV['ADAPTER']  = 'postgres'
    ENV['USERNAME'] = 'zen'

    sh(command)
  end

  # Task that ensures that the various Travis CI tests each use their own
  # database based on the Ruby version.
  desc 'Runs the tests for Travis CI'
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

    Dir.chdir(spec_dir)

    sh(command)
  end
end
