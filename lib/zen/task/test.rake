desc 'Runs all the RSpec specifications'
task :test do
  spec_dir = __DIR__('../../../spec')
  sh("cd #{spec_dir}; rake db:delete; rm resources/database.db; rake db:migrate; \
rake db:test_user; rspec zen/all.rb")
end
