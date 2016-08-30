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
      shared_examples 'runs a task' do |task_class|
        let(:task) do
          instance_double(task_class)
        end

        it "runs a #{task_class}" do
          expect(task_class).to receive(:new).and_return(task)
          expect(task).to receive(:run)
          Parallel.join
        end
      end

      context 'when Configuration#mock_mode is true' do
        before do
          Parallel.configuration.mock_mode = true
        end

        context 'and CIRCLE_NODE_INDEX is 0' do
          before do
            ENV['CIRCLE_NODE_INDEX'] = '0'
          end

          include_examples 'runs a task', Parallel::Task::MockMaster
        end

        context 'and CIRCLE_NODE_INDEX is other than 0' do
          before do
            ENV['CIRCLE_NODE_INDEX'] = '1'
          end

          include_examples 'runs a task', Parallel::Task::MockSlave
        end
      end

      context 'when Configuration#mock_mode is false' do
        before do
          Parallel.configuration.mock_mode = false
        end

        context 'and CIRCLE_NODE_INDEX is 0' do
          before do
            ENV['CIRCLE_NODE_INDEX'] = '0'
          end

          include_examples 'runs a task', Parallel::Task::Master
        end

        context 'and CIRCLE_NODE_INDEX is other than 0' do
          before do
            ENV['CIRCLE_NODE_INDEX'] = '1'
          end

          include_examples 'runs a task', Parallel::Task::Slave
        end
      end
    end
  end
end
