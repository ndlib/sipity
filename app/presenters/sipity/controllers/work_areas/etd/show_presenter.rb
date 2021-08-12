module Sipity
  module Controllers
    module WorkAreas
      module Etd
        # Present due to template lookup method
        class ShowPresenter < WorkAreas::Core::ShowPresenter
          self.additional_attributes = ["author_name", "etd_submission_date", "program_name"]

          def view_submitted_etds_url
            Figaro.env.curate_nd_url_for_etds!
          end

          def reset_path
            '/areas/etd'
          end
        end
      end
    end
  end
end
