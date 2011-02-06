desc "Generate the documentation using YARD"
task :doc do
  path = File.expand_path('../../', __FILE__)
  sh("yard doc #{path}/lib -m textile -M redcloth -o #{path}/doc -r #{path}/README.textile")
end