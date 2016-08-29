require 'circleci/parallel/task/master'
require 'circleci/parallel'
require 'circleci/parallel/build'
require 'circleci/parallel/configuration'
require 'circleci/parallel/node'

module CircleCI::Parallel
  RSpec.describe Task::Master do
    subject(:task) do
      Task::Master.new(node, configuration)
    end

    let(:node) do
      Node.new(build, 0)
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

    it 'downloads data from slave nodes when they are ready for download' do
      expect(Kernel).to receive(:system)
        .with('ssh', 'node1', 'test', '-f', '/tmp/circleci-parallel/JOINING')
        .and_return(false).ordered

      expect(Kernel).to receive(:system)
        .with('ssh', 'node2', 'test', '-f', '/tmp/circleci-parallel/JOINING')
        .and_return(false).ordered

      expect(Kernel).to receive(:system)
        .with('ssh', 'node1', 'test', '-f', '/tmp/circleci-parallel/JOINING')
        .and_return(false).ordered

      expect(Kernel).to receive(:system)
        .with('ssh', 'node2', 'test', '-f', '/tmp/circleci-parallel/JOINING')
        .and_return(true).ordered

      expect(Kernel).to receive(:system)
        .with('scp', '-r', 'node2:/tmp/circleci-parallel/data/node2', '/tmp/circleci-parallel/data')
        .and_return(true).ordered

      expect(Kernel).to receive(:system)
        .with('ssh', 'node2', 'touch', '/tmp/circleci-parallel/DOWNLOADED')
        .and_return(true).ordered

      expect(Kernel).to receive(:system)
        .with('ssh', 'node1', 'test', '-f', '/tmp/circleci-parallel/JOINING')
        .and_return(true).ordered

      expect(Kernel).to receive(:system)
        .with('scp', '-r', 'node1:/tmp/circleci-parallel/data/node1', '/tmp/circleci-parallel/data')
        .and_return(true).ordered

      expect(Kernel).to receive(:system)
        .with('ssh', 'node1', 'touch', '/tmp/circleci-parallel/DOWNLOADED')
        .and_return(true).ordered

      expect(Kernel).not_to receive(:system).ordered

      task.run
    end
  end
end
