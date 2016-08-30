require 'circleci/parallel/hook'

module CircleCI
  module Parallel
    class Configuration
      # @return [Boolean] whether progress messages should be outputted to STDOUT (default: false)
      attr_accessor :silent

      # @return [Boolean] whether mock mode is enabled (default: false)
      attr_accessor :mock_mode

      # @api private
      attr_reader :before_join_hook, :after_join_hook, :after_download_hook

      def initialize
        @silent = false
        @mock_mode = false
        @before_join_hook = @after_join_hook = @after_download_hook = Hook.new
      end

      # Defines a callback that will be invoked on all nodes before joining nodes.
      #
      # @param chdir [Boolean] whether the callback should be invoked while chaging the current
      #   working directory to the local data directory.
      #
      # @yieldparam local_data_dir [String] the path to the local data directory
      #
      # @return [void]
      #
      # @example
      #   CircleCI::Parallel.configure do |config|
      #     config.before_join do
      #       File.write('data.json', JSON.generate(some_data))
      #     end
      #   end
      #
      # @see CircleCI::Parallel.local_data_dir
      def before_join(chdir: true, &block)
        @before_join_hook = Hook.new(block, chdir)
      end

      # Defines a callback that will be invoked on all nodes after joining nodes.
      #
      # @param chdir [Boolean] whether the callback should be invoked while chaging the current
      #   working directory to the local data directory.
      #
      # @yieldparam local_data_dir [String] the path to the local data directory
      #
      # @return [void]
      #
      # @example
      #   CircleCI::Parallel.configure do |config|
      #     config.after_join do
      #       clean_some_intermediate_data
      #     end
      #   end
      #
      # @see CircleCI::Parallel.local_data_dir
      def after_join(chdir: true, &block)
        @after_join_hook = Hook.new(block, chdir)
      end

      # Defines a callback that will be invoked only on the master node after downloading all data
      # from slave nodes.
      #
      # @param chdir [Boolean] whether the callback should be invoked while chaging the current
      #   working directory to the download data directory.
      #
      # @yieldparam download_data_dir [String] the path to the download data directory
      #
      # @return [void]
      #
      # @example
      #   CircleCI::Parallel.configure do |config|
      #     config.after_download do
      #       merged_data = Dir['*/data.json'].each_with_object({}) do |path, merged_data|
      #         data = JSON.parse(File.read(path))
      #         node_name = File.dirname(path)
      #         merged_data[node_name] = data
      #       end
      #
      #       File.write('merged_data.json', JSON.generate(merged_data))
      #     end
      #   end
      #
      # @see CircleCI::Parallel.download_data_dir
      def after_download(chdir: true, &block)
        @after_download_hook = Hook.new(block, chdir)
      end
    end
  end
end
