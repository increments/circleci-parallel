require 'circleci/parallel/node'
require 'circleci/parallel/build'

module CircleCI::Parallel
  RSpec.describe Node do
    subject(:node) do
      Node.new(build, 1)
    end

    let(:build) do
      Build.new(123, 3)
    end

    describe '#other_nodes' do
      it 'returns other nodes for the build' do
        expect(node.other_nodes).to match([
          an_object_having_attributes(index: 0),
          an_object_having_attributes(index: 2)
        ])
      end
    end
  end
end
