# Don't worry, this will be obliterated by super secret environment bootstrap
# type things.
$stdout.puts "Creating User '#{ENV['USER']}' (from ENV['USER'])..."
user = User.find_or_create_by!(username: ENV['USER'])

graduate_school_reviewers = Sipity::DataGenerators::WorkTypes::EtdGenerator::GRADUATE_SCHOOL_REVIEWERS
$stdout.puts "Finding or creating group for '#{graduate_school_reviewers}'"
graduate_school = Sipity::Models::Group.find_or_create_by!(name: graduate_school_reviewers)

$stdout.puts "Associating #{user.username} with #{graduate_school.name}"
graduate_school.group_memberships.find_or_create_by(user: user)

catalogers = Sipity::DataGenerators::WorkTypes::EtdGenerator::CATALOGERS
$stdout.puts "Finding or creating group for '#{catalogers}'"
cataloging = Sipity::Models::Group.find_or_create_by!(name: catalogers)

$stdout.puts "Associating #{user.username} with #{cataloging.name}"
cataloging.group_memberships.find_or_create_by(user: user)

$stdout.puts "Creating User batch_ingestor"
batch_ingestor = User.find_or_create_by!(username: "batch_ingesting")

[Sipity::DataGenerators::WorkTypes::EtdGenerator::BATCH_INGESTORS].each do |ingestor_name|
  $stdout.puts "Finding or creating group for '#{ingestor_name}'"
  ingestor = Sipity::Models::Group.find_or_create_by!(name: ingestor_name)

  $stdout.puts "Associating batch_ingestor with #{ingestor.name}"
  etd_ingestor.group_memberships.find_or_create_by(user: ingestor)
end

ulra_review_committee_group_name = Sipity::DataGenerators::WorkTypes::UlraGenerator::ULRA_REVIEW_COMMITTEE_GROUP_NAME
$stdout.puts "Finding or creating group for '#{ulra_review_committee_group_name}'"
ulra_review_committee_group = Sipity::Models::Group.find_or_create_by!(name: ulra_review_committee_group_name)

$stdout.puts "Associating #{user.name} with #{ulra_review_committee_group.name}"
ulra_review_committee_group.group_memberships.find_or_create_by(user: batch_ingestor)

ulra_data_remediators = 'ULRA Data Remediators'
$stdout.puts "Finding or creating group for '#{ulra_data_remediators}'"
ulra_data_remediator_group = Sipity::Models::Group.find_or_create_by!(name: ulra_data_remediators)

$stdout.puts "Associating #{user.name} with #{ulra_data_remediator_group.name}"
ulra_data_remediator_group.group_memberships.find_or_create_by(user: user)
