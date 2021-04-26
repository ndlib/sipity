# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

SSHKit.config.command_map[:bundle] = '/usr/local/bin/bundle'
SSHKit.config.command_map[:rake] = "#{fetch(:bundle)} exec rake"
set :branch,    ENV["BRANCH_NAME"] || 'master'
set :rails_env, 'prep26'
set :deploy_to, '/home/app/sipity'
set :user,      'app'
set :domain,    fetch(:host, 'sipity-test.lc.nd.edu')
set :bundle_without, %w{development test doc}.join(' ')
set :shared_directories,  %w(log)
set :shared_files, %w()
#set :linked_files, ['config/database.yml']
server fetch(:domain), user: fetch(:user), roles: %w{web app db}


# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
