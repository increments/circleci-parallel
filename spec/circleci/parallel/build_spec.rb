module CircleCI::Parallel
  RSpec.describe Build do
    subject(:build) do
      Build.new(123, 3)
    end

    describe '#nodes' do
      it 'returns nodes for the build' do
        expect(build.nodes).to match([
          an_object_having_attributes(index: 0),
          an_object_having_attributes(index: 1),
          an_object_having_attributes(index: 2)
        ])
      end
    end
  end
end
