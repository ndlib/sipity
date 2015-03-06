# Don't worry, this will be obliterated by super secret environment bootstrap
# type things.
$stdout.puts "Creating User '#{ENV['USER']}' (from ENV['USER'])..."
User.find_or_create_by!(username: ENV['USER'])
