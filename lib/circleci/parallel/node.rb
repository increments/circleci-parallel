module CircleCI
  module Parallel
    Node = Struct.new(:build, :index) do
      def ==(other)
        build == other.build && index == other.index
      end

      alias_method :eql?, :==

      def master?
        index.zero?
      end

      # https://circleci.com/docs/ssh-between-build-containers/
      def ssh_host
        "node#{index}"
      end

      def data_dir
        File.join(BASE_DATA_DIR, ssh_host)
      end

      def other_nodes
        @other_nodes ||= (build.nodes - [self]).freeze
      end
    end
  end
end
