require 'sipity/forms/work_submissions/ulra/access_policy_form'
require 'sipity/forms/work_submissions/ulra/attach_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Exposes a means of assigning an access policy to each of the related
        # items.
        class AccessPolicyForm < WorkSubmissions::Core::AccessPolicyForm
          self.representative_attachment_predicate_name = Forms::WorkSubmissions::Ulra::AttachForm.attachment_predicate_name
        end
      end
    end
  end
end
