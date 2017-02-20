PowerConverter.define_conversion_for(:prepended_with_http) do |input|
  case input
  when String
    begin
      uri = URI.parse(input)
      if uri.host
        input
      else
        "http://#{input}"
      end
    rescue URI::InvalidURIError
      if input =~ %r{\Ahttps?://}
        input
      else
        "http://#{input}"
      end
    end
  end
end
