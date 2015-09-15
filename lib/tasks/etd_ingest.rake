namespace :sipity do
  desc 'Ingest ETD objects'
  task ingest_etds: :environment do
    Sipity::Models::Work.all.each do |work|
      Sipity::Exporters::EtdExporter.call(work)
    end
  end
end
