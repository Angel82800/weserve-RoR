rails_env = new_resource.environment["RAILS_ENV"]

Chef::Log.info("Adding ENV variables to Rails App...")

# map the environment_variables node to ENV
file ::File.join(release_path, 'config/application.yml') do
  content new_resource.environment.map { |k, v| "#{k}: #{v}" }.join("\n")
end


Chef::Log.info("Precompiling assets for RAILS_ENV=#{rails_env}...")

execute "rake assets:precompile" do
  cwd release_path
  command "bundle exec rake assets:precompile"
  environment "RAILS_ENV" => rails_env
end
