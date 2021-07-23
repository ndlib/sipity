require 'sipity/controllers/visitors/core/work_area_presenter'

module Sipity
  module Controllers
    module Visitors
      module Etd
        # Responsible for presenting the ETD work area to visitors
        class WorkAreaPresenter < Visitors::Core::WorkAreaPresenter
          def view_submitted_etds_url
            Figaro.env.curate_nd_url_for_etds!
          end

          def login_path
            new_user_session_path(previous_url: request.path)
          end
        end
      end
    end
  end
end
