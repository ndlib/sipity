# Don't worry, this will be obliterated by super secret environment bootstrap
# type things.
$stdout.puts "Creating User '#{ENV['USER']}' (from ENV['USER'])..."
user = User.find_or_create_by!(username: ENV['USER'])

$stdout.puts "Finding or creating group for 'Graduate School Reviewers'"
graduate_school = Sipity::Models::Group.find_or_create_by!(name: 'Graduate School Reviewers')

$stdout.puts "Associating #{user.username} with #{graduate_school.name}"
graduate_school.group_memberships.create(user: user) unless graduate_school.group_memberships.where(user: user)
