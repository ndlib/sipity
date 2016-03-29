PowerConverter.define_conversion_for(:rof_hash) do |input|
  case input
  when Sipity::Models::Attachment
    Sipity::Conversions::ToRofHash::AttachmentConverter.call(attachment: input)
  when Sipity::Models::Work
    Sipity::Conversions::ToRofHash::WorkConverter.call(work: input)
  end
end
