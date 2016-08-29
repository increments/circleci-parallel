require 'circleci/parallel/task/slave'
require 'circleci/parallel'
require 'circleci/parallel/build'
require 'circleci/parallel/configuration'
require 'circleci/parallel/node'

module CircleCI::Parallel
  RSpec.describe Task::Slave do
    subject(:task) do
      Task::Slave.new(node, configuration)
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
      allow(task).to receive(:downloaded?).and_return(true)
      expect { task.run }
        .to change { File.exist?('/tmp/circleci-parallel/JOINING') }.from(false).to(true)
    end

    it 'waits for master node to download' do
      expect(Kernel)
        .to receive(:sleep).ordered

      expect(Kernel)
        .to receive(:sleep) { File.write('/tmp/circleci-parallel/DOWNLOADED', '') }.ordered

      expect(Kernel)
        .not_to receive(:sleep).ordered

      task.run
    end
  end
end
