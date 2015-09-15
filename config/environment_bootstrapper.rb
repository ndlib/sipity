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
batch_ingestor = User.find_or_create_by!(username: 'batch_ingestor')

etd_ingestors = Sipity::DataGenerators::WorkTypes::EtdGenerator::ETD_INGESTORS
$stdout.puts "Finding or creating group for '#{etd_ingestors}'"
etd_ingestor = Sipity::Models::Group.find_or_create_by!(name: etd_ingestors)

$stdout.puts "Associating batch_ingestor with #{etd_ingestor.name}"
etd_ingestor.group_memberships.find_or_create_by(user: batch_ingestor)
