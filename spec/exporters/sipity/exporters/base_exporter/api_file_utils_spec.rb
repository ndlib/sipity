require "rails_helper"

module Sipity
  module Exporters
    class BaseExporter
      RSpec.describe ApiFileUtils do
        subject { described_class }
        it { is_expected.to respond_to :put_content }
        it { is_expected.to respond_to :mkdir_p }
        it { is_expected.to respond_to :mv }

        let(:path) { '/sample/path' }
        let(:destination) { '/somewhere/else' }

        describe 'method calls' do
          describe '#put_content' do
            it 'executes a put request to RestClient' do
              expect(RestClient).to receive(:put)
              expect(Sentry).not_to receive(:capture_exception)
              subject.put_content(path, nil)
            end

            context 'when error occurs' do
              before do
                allow(RestClient).to receive(:put).and_raise(RestClient::Exception)
              end
              it 'reports error' do
                expect(Sentry).to receive(:capture_exception)
                subject.put_content(path, destination)
              end
            end
          end

          describe '#mkdir_p' do
            it 'overrides FileUtils #mkdir_p and does nothing' do
              expect(subject).to receive(:mkdir_p).and_call_original
              subject.mkdir_p(path)
            end
          end

          describe '#mv' do
            it 'exeutes a post request to RestClient' do
              expect(RestClient).to receive(:post)
              expect(Sentry).not_to receive(:capture_exception)
              subject.mv(path, destination)
            end

            context 'when error occurs' do
              before do
                allow(RestClient).to receive(:post).and_raise(RestClient::Exception)
              end
              it 'reports error' do
                expect(Sentry).to receive(:capture_exception)
                subject.mv(path, destination)
              end
            end
          end
        end
      end
    end
  end
end
