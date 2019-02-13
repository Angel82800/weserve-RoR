#for a standalone unicorn and nginx deploy without relying on the Capistrano infrastructure
# may be disabled if we switch to Capistrano functionality at some point
# https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-unicorn-and-nginx-on-ubuntu-14-04
# set path to application
app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"
working_directory "#{app_dir}"


# Set unicorn options
worker_processes 2
preload_app true
timeout 30

# Set up socket location
#listen "#{shared_dir}/sockets/unicorn.sock", :backlog => 64
# It is better to run unicorn on port number rather than socket file to avoid permission conflicfts
listen "127.0.0.1:5080", :backlog => 64


# Logging
stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

# Set master PID location
pid "#{shared_dir}/pids/unicorn.pid"
