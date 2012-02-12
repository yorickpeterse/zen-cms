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
end
