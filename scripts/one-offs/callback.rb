# This script demonstrates how to call a callback end point
work_id = 'xO4iXDK2KdB2duXXpJR7sw=='
Sipity::Models::WorkRedirectStrategy.where(work_id: work_id).destroy_all
callback_url = Sipity::Exporters::BatchIngestExporter::WebhookWriter.send(:callback_url, work_id: work_id)
callback_url.gsub!(' ', '%20')
payload = {
  "host" => "curatewkrprod.library.nd.edu",
  "version" => "1.1.5",
  "job_name" => "sipity-#{work_id}",
  "job_state" => "success"
}
response = RestClient.post(callback_url, payload.to_json)
puts response.body
