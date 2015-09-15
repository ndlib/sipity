class EtdExportRunner

  def self.call
    new.run
  end

  def run
    target_entities do |work|
      obj = form.new(work: work, requested_by: etd_group)
      obj.submit
    end
  end

  private
  
  def etd_ingestors
    Sipity::DataGenerators::WorkTypes::EtdGenerator::ETD_INGESTORS
  end

  def etd_group
    Sipity::Models::Group.find_or_create_by!(name: etd_ingestors)
  end

  def form
    Sipity::Forms::WorkSubmissions::Etd::SubmitForIngestForm
  end

  def etd_work_area
    PowerConverter.convert_to_work_area('etd')
  end

  def each_etd_entities
    Sipity::Models::WorkSubmission.find_each do |work_submission|
      yield(convert_to_entity(work_submission.work)) if work_submission.work_area == etd_work_area
    end
  end

  def convert_to_entity(work)
    Sipity::Conversions::ConvertToProcessingEntity.call(work)
  end

  def target_entities
    each_etd_entities do |entity|
      yield(entity.proxy_for) if entity.strategy_state.name == 'ready_for_ingest'
    end
  end
end

EtdExportRunner.call
