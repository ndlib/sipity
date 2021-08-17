if ENV['COV'] || ENV['COVERAGE'] || ENV['TRAVIS']
  if ENV['TRAVIS']
    require 'simplecov'
    SimpleCov.start do
      formatter(
        SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter])
      )
      load_profile 'rails'
    end
  elsif ENV['COV'] || ENV['COVERAGE']
    require 'simplecov'

    if ENV['COV_PROFILE']
      coverage_profile_name = ENV['COV_PROFILE']
      SimpleCov.profiles.define "sipity.#{coverage_profile_name}" do
        load_profile 'rails'
        require 'rake/file_list'
        pattern = File.expand_path('../../app/*', __FILE__)

        Rake::FileList[pattern].exclude { |path| path =~ %r{app/#{coverage_profile_name}} }.each do |path|
          add_filter path
        end
        add_filter 'lib'
      end
      SimpleCov.start do
        load_profile "sipity.#{coverage_profile_name}"
      end
    else
      SimpleCov.start { load_profile 'rails' }
    end
  end
end
