class RemediateHtmlEntities < ActiveRecord::Migration[4.2]
  def self.up
    model = Sipity::Models::AdditionalAttribute
    model.find_each do |additional_attribute|
      scrubber = model.scrubber_for(predicate_name: additional_attribute.key)
      scrubbed_value = scrubber.sanitize(additional_attribute.value)
      additional_attribute.update_column(:value, scrubbed_value)
    end

    inline_scrubber = Hesburgh::Lib::HtmlScrubber.build_inline_scrubber
    Sipity::Models::Work.find_each do |work|
      scrubbed_title = inline_scrubber.sanitize(work.title)
      work.update_column(:title, scrubbed_title)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
