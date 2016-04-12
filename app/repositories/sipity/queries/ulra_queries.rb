module Sipity
  module Queries
    # Queries specific to ULRA
    module UlraQueries
      def possible_expected_graduation_terms(ending_year: Time.zone.today.year, **_keywords)
        (-1..3).each_with_object([]) do |year_delta, values|
          year = ending_year.to_i + year_delta
          ['Spring', 'Summer', 'Fall'].each do |season|
            values << "#{season} #{year}"
          end
        end
      end

      # NOTE: These are PIDs for the production environment, but for Sipity tests they are inconsequential.
      SUBMISSION_WINDOW_COLLECTION_IDS = {
        "ulra.2016.participant" => 'und:pr76f190g2d',
        "ulra.2016.award_recipient" => 'und:pv63fx73r3n'
      }.freeze
      private_constant :SUBMISSION_WINDOW_COLLECTION_IDS

      # @api private
      #
      # Responsible for capturing the appropriate collections to assign to ULRA submissions based on their award status.
      #
      # TODO: Extract this to a property storage. I'm wondering if extending the AdditionalAttributes makes sense; I believe that is an
      # appropriate mechanism. There is a larger refactor that could be done related to that information.
      def collection_pid_for(submission_window:, key:)
        submission_window = PowerConverter.convert(submission_window, to: :submission_window)
        work_area = PowerConverter.convert(submission_window, to: :work_area)
        SUBMISSION_WINDOW_COLLECTION_IDS.fetch("#{work_area.slug}.#{submission_window.slug}.#{key}")
      end
    end
  end
end
