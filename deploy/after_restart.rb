rails_env = new_resource.environment["RAILS_ENV"]

Chef::Log.info("Generating new crontab ")

execute "generate-new-crontab" do
  environment "RAILS_ENV" => rails_env
  only_if { ['weserve-staging-1', 'weserve-production-1', 'weserve-beta-1'].include? node["opsworks"]["instance"]["hostname"] }
  cwd release_path
  user "deploy"
  group "www-data"
  command "bundle exec whenever --write-crontab #{release_path}/config/schedule.rb"
  action :run
end
