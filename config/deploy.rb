# config valid only for Capistrano 3.1
lock '3.3.5'
set :default_env, {
  path: "/opt/ruby/current/bin:$PATH"
}
set :bundle_roles, [:app, :work]
set :bundle_flags, "--deployment --path=vendor/bundle"
set :bundle_cmd, "/opt/ruby/current/bin/bundle"
set :bundle_without, %w{development test doc}.join(' ')
set :application, 'sipity'
set :scm, :git
set :repo_url, "https://github.com/ndlib/sipity.git"
set :branch, 'master'

set :keep_releases, 5
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :secret_repo_name, Proc.new{
  case fetch(:rails_env)
  when 'staging' then 'secret_staging'
  when 'pre_production' then 'secret_pprd'
  when 'production' then 'secret_prod'
  end
}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute "touch #{release_path}/tmp/restart.txt"
    end
  end

  task :db_create do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:create"
        end
      end
    end
  end

  task :db_migrate do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:migrate"
        end
      end
    end
  end

  task :precompile_assets do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "assets:precompile"
        end
      end
    end
  end

  desc 'Seed the database'
  task :db_seed do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:seed sipity:environment_bootstrapper"
        end
      end
    end
  end
end

namespace :configuration do
  task :copy_secrets do
    on roles(:app) do
      within release_path do
        execute "export PATH=/opt/ruby/current/bin:$PATH && cd #{release_path} && sh scripts/update_secrets.sh #{fetch(:secret_repo_name)}"
      end
    end
  end
end
