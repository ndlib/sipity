module Sipity
  module Controllers
    # Responsible for assisting in the normalization of the translations in a
    # predictable and repeatable manner.
    module TranslationAssistantForPolymorphicType
      module_function

      # This .call is ultimately resonsible for building the strategy for
      # looking up translation options and injecting appropriate information.
      #
      # Below is the sequence of keys that we will attempt to translate.
      #
      # 1. :<scope>.models/<polymorphic_type param_key>.<object>.<predicate>
      # 2. :<scope>.<object>.<predicate>
      # 3. <object.to_s.humanize>
      def call(scope:, subject:, object: subject, predicate:)
        scope = scope.to_s
        defaults = [:"#{object}.#{predicate}", object.to_s.humanize]
        options = { scope: scope, default: defaults }

        inject_polymorphic_type(subject: subject, defaults: defaults)

        first_key_to_try = defaults.shift
        I18n.translate(first_key_to_try, options).html_safe
      rescue I18n::MissingInterpolationArgument => e
        Rails.logger.debug("#{e.class}: #{e.message}. Falling back to default.")
        object.to_s.humanize
      end

      def inject_polymorphic_type(subject:, defaults:)
        polymorphic_type = PowerConverter.convert(subject, to: :polymorphic_type)
        defaults.unshift(:"models/#{polymorphic_type.model_name.param_key}.#{defaults[-2]}")
      rescue Exceptions::EntityTypeConversionError, PowerConverter::ConversionError
        # Nothing need happen hear
        nil
      end
      private_class_method :inject_polymorphic_type
    end
  end
end
