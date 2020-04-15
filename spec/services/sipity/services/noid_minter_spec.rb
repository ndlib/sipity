require 'rails_helper'
require 'sipity/services/noid_minter'
require 'noids_client/integration_test' if ENV["WITH_NOIDS_SERVER"]

module Sipity
  module Services
    describe NoidMinter do
      let(:pid) { "pid" }
      let(:pool) { double("Minter", mint: [pid]) }
      let(:connection) { double("Connection", get_pool: pool) }
      context '.call' do
        it 'will mint a pid' do
          expect(NoidsClient::Connection).to(
            receive(:new).with("#{Figaro.env.noid_server}:#{Figaro.env.noid_port}").and_return(connection)
          )
          expect(connection).to(
            receive(:get_pool).with(Figaro.env.noid_pool).and_return(pool)
          )
          expect(described_class.call).to eq(pid)
        end
      end

      if ENV["WITH_NOIDS_SERVER"]
        context 'with "live" NOIDs server' do
          # A bit of hard-coded magic. These are the default hosts and ports
          let(:noid_server) { "http://localhost" }
          let(:noid_port) { "13001" }
          let(:noid_pool_name) { "test" }
          it 'will mint a pid' do
            ::NoidsClient::IntegrationTest::NoidServerRunner.new.run do
              # Sipity assumes that the noid_pool already exists. It is the one
              # CurateND has been using.
              noid_minter = described_class.new(server: noid_server, port: noid_port, pool_name: noid_pool_name)
              noid_minter.connection.new_pool("test", ".sddd")
              expect(noid_minter.call).to eq("000")
              expect(noid_minter.call).to eq("001")
            end
          end
        end
      else
        $stdout.puts %(\n\n\n)
        $stdout.puts %(Skipping "live" test of noids minter.)
        $stdout.puts %(To run with a live menter, run the test suite with ENV["WITH_NOIDS_SERVER"] of true)
        $stdout.puts %(\n\n\n)
      end
    end
  end
end
