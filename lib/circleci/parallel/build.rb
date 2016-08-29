require 'circleci/parallel/node'

module CircleCI
  module Parallel
    Build = Struct.new(:number, :node_count) do
      def ==(other)
        number == other.number
      end

      alias_method :eql?, :==

      def nodes
        @nodes ||= Array.new(node_count) { |index| Node.new(self, index) }.freeze
      end
    end
  end
end
