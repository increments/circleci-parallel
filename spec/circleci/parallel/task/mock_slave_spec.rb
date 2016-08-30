require 'circleci/parallel/task/mock_slave'
require 'circleci/parallel'
require 'circleci/parallel/build'
require 'circleci/parallel/configuration'
require 'circleci/parallel/node'

module CircleCI::Parallel
  RSpec.describe Task::MockSlave do
    subject(:task) do
      Task::MockSlave.new(node, configuration)
    end

    let(:node) do
      Node.new(build, 1)
    end

    let(:build) do
      Build.new(123, 3)
    end

    let(:configuration) do
      Configuration.new
    end

    it 'creates join marker file' do
      expect { task.run }
        .to change { File.exist?('/tmp/circleci-parallel/JOINING') }.from(false).to(true)
    end
  end
end
