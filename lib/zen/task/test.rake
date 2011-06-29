desc 'Runs all the Bacon specifications'
task :test do
  spec_dir = __DIR__('../../../spec')
  sh("cd #{spec_dir}; rake db:delete; rm database.db; rake db:migrate; \
rake db:test_user; ruby zen/all.rb")
end
