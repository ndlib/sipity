$stdout.puts 'Creating Groups...'
graduate_school_reviewers = Sipity::DataGenerators::WorkTypes::EtdGenerator::GRADUATE_SCHOOL_REVIEWERS
catalogers = Sipity::DataGenerators::WorkTypes::EtdGenerator::CATALOGERS
Sipity::Conversions::ConvertToProcessingActor.call(
  Sipity::Models::Group.find_or_create_by!(name: graduate_school_reviewers)
)
Sipity::Conversions::ConvertToProcessingActor.call(
  Sipity::Models::Group.find_or_create_by!(name: catalogers)
)

$stdout.puts 'Add existing users to All Registered Users Groups...'
Sipity::Models::Group.find_or_create_by!(name: Sipity::Models::Group::ALL_REGISTERED_USERS)

$stdout.puts 'Creating Valid Roles...'
Sipity::Models::Role.valid_names.each do |name|
  Sipity::Models::Role.find_or_create_by!(name: name)
end
