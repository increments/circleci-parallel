require 'fileutils'

module CircleCI
  module Parallel
    module Task
      # @api private
      class Base
        attr_reader :node, :configuration

        def initialize(node, configuration)
          @node = node
          @configuration = configuration
        end

        def run
          raise NotImplementedError
        end

        private

        def create_node_data_dir
          FileUtils.makedirs(node.data_dir)
        end

        def mark_as_joining
          Parallel.puts('Joining CircleCI nodes...')
          File.write(JOIN_MARKER_FILE, '')
        end

        def done
          Parallel.puts('Done.')
        end
      end
    end
  end
end
