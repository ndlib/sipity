# Because of the above `const_defined?` I'm requiring the various sipity
# jobs
Dir[File.expand_path('../jobs/*.rb', __FILE__)].each do |filename|
  require_relative "./jobs/#{File.basename(filename)}"
end
module Sipity
  # Responsible for processing a single concept in an asynchronous manner.
  # That means we are only passing primatives to the Jobs and it is
  # the Jobs responsibility to reify the correct objects.
  #
  # @see https://github.com/resque/resque Resque gem
  module Jobs
    module_function

    # Herein lies the inflection point. If you want to run things
    # asynchronously, this is your place to make changes.
    def submit(job_name, *args)
      job = find_job_by_name(job_name)

      # REVIEW: Would it make sense to verify that each of the args is a
      #   primative? Given that we could be passing this information through
      #   REDIS
      job.submit(*args)
    end

    def find_job_by_name(job_name)
      job_name_as_constant = job_name.to_s.classify
      if const_defined?(job_name_as_constant)
        const_get(job_name_as_constant)
      else
        fail Exceptions::JobNotFoundError, name: job_name, container: self
      end
    end
    private_class_method :find_job_by_name
  end
end
