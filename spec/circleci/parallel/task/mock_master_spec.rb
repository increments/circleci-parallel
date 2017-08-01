module CircleCI::Parallel
  RSpec.describe Task::MockMaster do
    subject(:task) do
      Task::MockMaster.new(node, configuration)
    end

    let(:node) do
      Node.new(build, 0)
    end

    let(:build) do
      Build.new(123, 3)
    end

    let(:configuration) do
      Configuration.new.master_node_configuration
    end

    it 'creates sync marker file' do
      expect { task.run }
        .to change { File.exist?('/tmp/circleci-parallel/SYNCING') }.from(false).to(true)
    end

    it 'creates download marker file in the local' do
      expect { task.run }
        .to change { File.exist?('/tmp/circleci-parallel/DOWNLOADED') }.from(false).to(true)
    end
  end
end
