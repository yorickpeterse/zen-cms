desc 'Runs all the Bacon specifications'
task :test => ['clean:assets'] do
  spec_dir = File.expand_path('../../../../spec', __FILE__)
  db_path  = File.join(spec_dir, 'database.db')

  File.unlink(db_path) if File.exist?(db_path)

  sh("cd #{spec_dir}; rake db:migrate; rake db:test_user; ruby zen/all.rb")
end
