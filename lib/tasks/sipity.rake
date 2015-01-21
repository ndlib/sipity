namespace :sipity do
  desc 'Build the various repository interfaces for testing purposes; These are descriptive interfaces'
  task :rebuild_interfaces do
    Rake::Task['sipity:build_command_repository_interface'].invoke unless ENV['TRAVIS']
  end

  desc 'Builds the interface for the command repository; Useful for testing purposes'
  task :build_command_repository_interface do
    MethodDefinition = Struct.new(:name, :definition, :source_filename)
    method_definitions = []

    dirname = File.expand_path('../../../app/repositories/sipity/commands/**/*.rb', __FILE__)

    # Gather all of the command methods
    Dir.glob(dirname).each do |filename|
      File.read(filename).each_line do |line|
        if line =~ /^ *def ([\w]*)[^\w].*$/
          method_name = $1
          # This is a potentially big problem that I want to address.
          if method_definitions.detect { |m| m.name == method_name }
            $stderr.puts "Duplicate method_name encountered. \"#{method_name}\" has been defined in multiple files."
            exit(1)
          else
            filename.sub!(/^.*\/app\//, './app/')
            method_definitions << MethodDefinition.new(method_name, line.strip, filename)
          end
        end
      end
    end

    # Be kind, lets put the methods in the file in alphabetical order.
    method_definitions.sort! { |a,b| a.name <=> b.name }

    # Write a Sipity::CommandRepositoryInterface object for use in testing.
    mock_repository_filename = File.expand_path('../../../spec/support/sipity/command_repository_interface.rb', __FILE__)
    File.open(mock_repository_filename, 'w+') do |file|
      file.puts "module Sipity"
      file.puts "  class CommandRepositoryInterface"
      method_definitions.each do |method|
        file.puts "    # @see #{method.source_filename}"
        file.puts "    #{method.definition}"
        file.puts "    end"
        file.puts ""
      end
      file.puts "  end"
      file.puts "end"
    end
  end

  task :stats_setup do
    require 'rails/code_statistics'
    types = begin
      dirs = Dir['./app/**/*.rb'].map { |f| f.sub(%r{^\./(app/\w+)/.*}, '\\1') }.uniq.select { |f| File.directory?(f) }
      Hash[dirs.map { |d| [d.split('/').last, d] }]
    end

    types.each do |type, dir|
      name = type.pluralize.capitalize
      ::STATS_DIRECTORIES << [name, dir] unless ::STATS_DIRECTORIES.find { |array| array[0] == name }
    end
    ::STATS_DIRECTORIES.sort!
  end
end
