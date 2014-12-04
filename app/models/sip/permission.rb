module Sip
  # Sits between a user and a subject defining the role for access.
  class Permission < ActiveRecord::Base
    self.table_name = 'sip_permissions'
    belongs_to :user
    belongs_to :subject, polymorphic: true
  end
end
