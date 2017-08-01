require 'circleci/parallel'
require 'json'

RSpec.describe CircleCI::Parallel do
  before(:context) do
    raise 'This spec must be run with 2 parallelism' unless ENV['CIRCLE_NODE_TOTAL'] == '2'
  end

  context 'with `on_every_node.before_sync`, `on_master_node.after_download`, and `on_every_node.after_sync`' do
    before do
      @invoked_before_sync_hook = false
      @invoked_after_sync_hook = false
      @merged_data = {}

      CircleCI::Parallel.configure do |config|
        config.silent = true

        config.on_every_node.before_sync do
          data = { 'index' => ENV['CIRCLE_NODE_INDEX'] }
          json = JSON.generate(data)
          File.write('data.json', json)
          @invoked_before_sync_hook = true
        end

        config.on_master_node.after_download do
          Dir.glob('*/data.json') do |path|
            json = File.read(path)
            data = JSON.parse(json)
            node_name = File.dirname(path)
            @merged_data[node_name] = data
          end
        end

        config.on_every_node.after_sync do
          File.delete('data.json')
          @invoked_after_sync_hook = true
        end
      end
    end

    context 'on CIRCLE_NODE_INDEX 0 node', if: ENV['CIRCLE_NODE_INDEX'] == '0' do
      let(:expected_merged_data) do
        {
          'node0' => { 'index' => '0' },
          'node1' => { 'index' => '1' }
        }
      end

      it 'invokes all the hooks' do
        expect { CircleCI::Parallel.sync }
          .to change { @invoked_before_sync_hook }.from(false).to(true)
          .and change { @invoked_after_sync_hook }.from(false).to(true)
          .and change { @merged_data }.to(expected_merged_data)
      end
    end

    context 'on CIRCLE_NODE_INDEX 1 node', if: ENV['CIRCLE_NODE_INDEX'] == '1' do
      it 'invokes only before_sync and after_sync hooks' do
        expect { CircleCI::Parallel.sync }
          .to change { @invoked_before_sync_hook }.from(false).to(true)
          .and change { @invoked_after_sync_hook }.from(false).to(true)
          .and not_change { @merged_data }
      end
    end
  end
end
