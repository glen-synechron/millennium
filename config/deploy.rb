require "rvm"

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

set :rvm_ruby_string, 'ruby-1.9.3-p194@beautybook'
set :rvm_type, :user  # Copy the exact line. I really mean :user here

set :rvm_path,          "/usr/local/rvm"
set :rvm_bin_path,      "#{rvm_path}/bin"
set :rvm_lib_path,      "#{rvm_path}/lib"


set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ruby-1.9.3-p194@global/bin:/usr/local/rvm/bin:/usr/local/rvm/rubies/ruby-1.9.3-p125/bin:$PATH",
  'RUBY_VERSION' => 'ruby-1.9.3-p125',
  'GEM_HOME'     => '/usr/local/rvm/gems/ruby-1.9.3-p194',
  'GEM_PATH'     => '/usr/local/rvm/gems/ruby-1.9.3-p194@global',
  'BUNDLE_PATH'  => '/usr/local/rvm/gems/ruby-1.9.3-p194@global'  # If you are using bundler.
}

set :domain ,'108.166.82.56'
set :user, "root"
set :application, "millennium"
set :repository, 'git@github.com:glen-synechron/millennium.git' ###need to change
set :scm, :git
set :branch, "master"
set :scm_verbose, true
set :deploy_via, :remote_cache
set :keep_releases, 5
#set :deploy_via, :copy
set :deploy_to, "/var/www/#{application}"
set :use_sudo, true
#set :rvm_type, :user
set :stages, %w(development production)
set :default_stage, 'production'
set :normalize_asset_timestamps, false


role :app, domain
role :web, domain
role :db,  domain, :primary => true

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :runner, user
#set :bundle_cmd, 'rvmsudo bundle'

after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  desc "Copy config files"
  #
  after "deploy:update_code" do
    run "export RAILS_ENV=production"
    run "ln -nfs #{shared_path}/public/assets #{release_path}/public/assets"
    run "ln -nfs #{shared_path}/log #{release_path}/log"
    run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"
    run "cp #{shared_path}/config/database.yml #{release_path}/config/"
    sudo "chmod -R 0777 #{release_path}/tmp/"
    sudo "chmod -R 0777 #{release_path}/log/"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

=begin used when you want to seed the database
  desc "Seed the database"
  task :seed, :roles => :db do
    # on_rollback { deploy.db.restore }
    run "cd #{current_path}"
    run "rake db:seed RAILS_ENV=staging"
    run "rake spree_sample:load RAILS_ENV=staging"
  end
=end
  
  desc 'run bundle install'
  task :bundle_install, :roles => :app do
    run "cd #{current_path} && bundle install --deployment --path #{shared_path}/bundle"
  end

  desc "Reset the database"
  task :reset, :roles => :db do
    # on_rollback { deploy.db.restore }
    run "cd #{current_path}"
    run "rake db:migrate:reset" #{}RAILS_ENV=staging
  end

  task :cleanup do
    #do nothing
  end

end

after "deploy:create_symlink", "deploy:bundle_install"

#before 'deploy:update_code', 'thinking_sphinx:stop'
#after 'deploy:update_code', 'thinking_sphinx:start'
#
#namespace :sphinx do
#  desc "Symlink Sphinx indexes"
#  task :symlink_indexes, :roles => [:app] do
#    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
#  end
#end
#
#after 'deploy:finalize_update', 'sphinx:symlink_indexes'


namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end

  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
#    run "cd #{release_path} && source $HOME/.bash_profile && bundle install"
  end
end

#namespace :rvm do
#  task :trust_rvmrc do
#    run( "rvm rvmrc trust #{release_path}")
#  end
#end

after 'deploy:finalize_update', 'bundler:bundle_new_release'
#after "deploy", "rvm:trust_rvmrc"
