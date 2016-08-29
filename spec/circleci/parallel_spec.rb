require 'circleci/parallel'

module CircleCI
  RSpec.describe Parallel do
    around do |example|
      original_env = ENV.to_h
      example.run
      ENV.replace(original_env)
    end

    before do
      ENV['CIRCLECI'] = 'true'
      ENV['CIRCLE_BUILD_NUM'] = '123'
      ENV['CIRCLE_NODE_TOTAL'] = '3'
      ENV['CIRCLE_NODE_INDEX'] = '1'
    end

    describe '.current_build' do
      it 'returns a Build for the current CircleCI environment' do
        expect(Parallel.current_build).to have_attributes(
          number: 123,
          node_count: 3
        )
      end
    end

    describe '.current_node' do
      it 'returns a Node for the current CircleCI environment' do
        expect(Parallel.current_node).to have_attributes(
          build: Parallel.current_build,
          index: 1
        )
      end
    end

    describe '.local_data_dir' do
      subject do
        Parallel.local_data_dir
      end

      context 'when CIRCLE_NODE_INDEX is 1' do
        before do
          ENV['CIRCLE_NODE_INDEX'] = '1'
        end

        it { should eq('/tmp/circleci-parallel/data/node1') }
      end
    end

    describe '.download_data_dir' do
      subject do
        Parallel.download_data_dir
      end

      it { should eq('/tmp/circleci-parallel/data') }
    end

    describe '.join' do
      context 'when CIRCLE_NODE_INDEX is 0' do
        before do
          ENV['CIRCLE_NODE_INDEX'] = '0'
        end

        let(:task) do
          instance_double(Parallel::Task::Master)
        end

        it 'runs a Task::Master' do
          expect(Parallel::Task::Master).to receive(:new).and_return(task)
          expect(task).to receive(:run)
          Parallel.join
        end
      end

      context 'when CIRCLE_NODE_INDEX is other than 0' do
        before do
          ENV['CIRCLE_NODE_INDEX'] = '1'
        end

        let(:task) do
          instance_double(Parallel::Task::Slave)
        end

        it 'runs a Task::Slave' do
          expect(Parallel::Task::Slave).to receive(:new).and_return(task)
          expect(task).to receive(:run)
          Parallel.join
        end
      end
    end
  end
end
