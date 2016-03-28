require 'power_converter'
PowerConverter.define_conversion_for(:exporter_function) do |input|
  if input.respond_to?(:call)
    input
  else
    case input
    when String
      base_class_name = "#{input}Exporter".classify
      if Sipity::Exporters.const_defined?(base_class_name)
        Sipity::Exporters.const_get(base_class_name)
      end
    end
  end
end
