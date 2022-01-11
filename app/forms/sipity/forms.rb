module Sipity
  # Contains the various Forms associated with Sipity.
  #
  # Forms are a class of objects that are different from models. They may
  # represent a subset of a single model's attributes, or be a composition of
  # multiple objects.
  #
  # A form's purpose is to:
  #
  #   * Expose attributes
  #   * Validate attributes
  #
  # They are things that could be rendered via the `simple_form_for` view
  # template method.
  #
  # In the case of Forms, I want to avoid exposing means of updating the data
  # after initialization. That means no attribute accessors; Because adding
  # public setter methods means I have to worry about mutability after
  # initialization. Perhaps not a big deal, but if I can avoid that problem,
  # I'd much prefer to. One added benefit is that I can do simple "change"
  # checks without having to manage more internal state of the object.
  #
  # @note By introducing Forms, there is less of a reliance on the anti-pattern
  #   of Strong Parametesr. That is to say, only expose explicit attributes to
  #   the UI. And should the controller be the thing saying what parameters are
  #   permitted for mass assignment? Not if you intend to create command line
  #   tools.
  # @see [Nick Sutterer's Reform gem](http://github.com/apotonick/reform) for
  #   additional commentary and reason for separating forms from their
  #   underlying ActiveRecord classes.
  module Forms
    unless (const_defined?(:STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME))
      STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME = 'state_advancing_action_confirmation'.freeze
    end
  end
end
