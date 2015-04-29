$stdout.puts 'Creating Groups...'
GRADUATE_SCHOOL_REVIEWERS = 'Graduate School Reviewers' unless defined?(GRADUATE_SCHOOL_REVIEWERS)
Sipity::Conversions::ConvertToProcessingActor.call(
  Sipity::Models::Group.find_or_create_by!(name: GRADUATE_SCHOOL_REVIEWERS)
)

$stdout.puts 'Add existing users to All Registered Users Groups...'
Sipity::Models::Group.find_or_create_by!(name: Sipity::Models::Group::ALL_REGISTERED_USERS)
#add existing users to that group (unless they are already there)
Sipity::Models::User.all.each do |user|
  Sipity::DataGenerators::OnUserCreate.call(user)
end

$stdout.puts 'Creating Valid Roles...'
Sipity::Models::Role.valid_names.each do |name|
  Sipity::Models::Role.find_or_create_by!(name: name)
end
