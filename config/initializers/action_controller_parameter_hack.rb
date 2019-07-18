require 'action_controller/metal/strong_parameters'

# In moving from Rails 4.x to 5.x, Rails adjusted the parameter object
# from a HashWithIndifferentAccess to an ActionController::Parameters
# object. The impact is methods that Sipity assumed no longer exist.
# This hack address those issues.
#
# In a lament, I look to all of the form objects and how creating a
# simple hash to pass to them does not reflect the reality of the
# application's actual behavior.
#
# This monkey patch restores the features that I was hoping to continue
# to leverage.
class ActionController::Parameters
  def with_indifferent_access
    self
  end

  def symbolize_keys
    self
  end

  def symbolize_keys!
    self
  end

  def map()
    objects = []
    each do |*args|
      objects << yield(*args)
    end
    objects
  end
end
