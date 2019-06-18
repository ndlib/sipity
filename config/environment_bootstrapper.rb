# Don't worry, this will be obliterated by super secret environment bootstrap
# type things.
require 'sipity/command_repository'

command_repository = Sipity::CommandRepository.new

$stdout.puts "Creating User '#{ENV['USER']}' (from ENV['USER'])..."
user = User.find_or_create_by!(username: ENV['USER'])

graduate_school_reviewers = Sipity::DataGenerators::WorkTypes::EtdGenerator::GRADUATE_SCHOOL_REVIEWERS
$stdout.puts "Finding or creating group for '#{graduate_school_reviewers}'"
$stdout.puts "Associating #{user.username} with #{graduate_school_reviewers}"
command_repository.set_group_membership(group_name: graduate_school_reviewers, usernames: [user.username])

catalogers = Sipity::DataGenerators::WorkTypes::EtdGenerator::CATALOGERS
$stdout.puts "Finding or creating group for '#{catalogers}'"
$stdout.puts "Associating #{user.username} with #{catalogers}"
command_repository.set_group_membership(group_name: catalogers, usernames: [user.username])


batch_ingestor_name = Sipity::Models::Group::BATCH_INGESTORS
$stdout.puts "Finding or batch ingestors for '#{batch_ingestor_name}'"
$stdout.puts "Creating User batch_ingestor"
command_repository.set_group_membership(group_name: catalogers, usernames: ['batch_ingesting'])
batch_ingestor = Sipity::Models::Group.find_by!(name: batch_ingestor_name)
batch_ingestor.update!(api_key: Figaro.env.sipity_access_key_for_batch_ingester!)

$stdout.puts "Finding or batch ingestors for '#{Sipity::Models::Group::ETD_INTEGRATORS}'"
integrator = Sipity::Models::Group.find_or_create_by!(name: Sipity::Models::Group::ETD_INTEGRATORS)
integrator.update!(api_key: Figaro.env.sipity_access_key_for_etd_integrators!)

ulra_review_committee_group_name = Sipity::DataGenerators::WorkTypes::UlraGenerator::ULRA_REVIEW_COMMITTEE_GROUP_NAME
$stdout.puts "Finding or creating group for '#{ulra_review_committee_group_name}'"
$stdout.puts "Associating #{user.name} with #{ulra_review_committee_group_name}"
command_repository.set_group_membership(group_name: ulra_review_committee_group_name, usernames: [user.username])

ulra_data_remediators = 'ULRA Data Remediators'
$stdout.puts "Finding or creating group for '#{ulra_data_remediators}'"
$stdout.puts "Associating #{user.name} with #{ulra_data_remediators}"
command_repository.set_group_membership(group_name: ulra_data_remediators, usernames: [user.username])
