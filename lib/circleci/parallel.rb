require 'fileutils'
require 'forwardable'
require 'circleci/parallel/environment'

module CircleCI
  # Provides simple APIs for joining CircleCI's parallel builds and sharing files between the
  # builds.
  #
  # @example
  #   merged_data = {}
  #
  #   CircleCI::Parallel.configure do |config|
  #     config.before_join do
  #       data = do_something
  #       json = JSON.generate(data)
  #       File.write('data.json', json)
  #     end
  #
  #     config.after_download do
  #       Dir.glob('*/data.json') do |path|
  #         json = File.read(path)
  #         data = JSON.parse(json)
  #         node_name = File.dirname(path)
  #         merged_data[node_name] = data
  #       end
  #     end
  #   end
  #
  #   CircleCI::Parallel.join
  #
  #   p merged_data
  module Parallel
    extend SingleForwardable

    # @api private
    WORK_DIR = '/tmp/circleci-parallel'.freeze

    # @api private
    BASE_DATA_DIR = File.join(WORK_DIR, 'data')

    # @api private
    JOIN_MARKER_FILE = File.join(WORK_DIR, 'JOINING')

    # @api private
    DOWNLOAD_MARKER_FILE = File.join(WORK_DIR, 'DOWNLOADED')

    # @!method configuration

    # @!scope class
    #
    # Returns the current configuration.
    #
    # @return [Configuration] the current configuration
    #
    # @see .configure
    def_delegator :environment, :configuration

    # @!method configure
    #
    # @!scope class
    #
    # Provides a block for configuring RSpec::ComposableJSONMatchers.
    #
    # @yieldparam config [Configuration] the current configuration
    #
    # @return [void]
    #
    # @example
    #   CircleCI::Parallel.configure do |config|
    #     config.silent = true
    #   end
    #
    # @see .configuration
    def_delegator :environment, :configure

    # @!method current_build
    #
    # @!scope class
    #
    # Returns the current CircleCI build.
    #
    # @return [Build] the current build
    #
    # @see .current_node
    def_delegator :environment, :current_build

    # @!method current_node
    #
    # @!scope class
    #
    # Returns the current CircleCI node.
    #
    # @return [Build] the current node
    #
    # @see .current_build
    def_delegator :environment, :current_node

    # @!method join
    #
    # @!scope class
    #
    # Join all nodes in the same build and gather all node data into the master node.
    # Invoking this method blocks until the join and data downloads are complete.
    #
    # @raise [RuntimeError] when `CIRCLECI` environment variable is not set
    #
    # @see CircleCI::Parallel::Configuration#before_join
    # @see CircleCI::Parallel::Configuration#after_join
    # @see CircleCI::Parallel::Configuration#after_download
    def_delegator :environment, :join

    # @api private
    # @!method puts
    # @!scope class
    def_delegator :environment, :puts

    class << self
      # Returns the local data directory where node specific data should be saved in.
      #
      # @return [String] the local data directory
      #
      # @example
      #   path = File.join(CircleCI::Parallel.local_data_dir, 'data.json')
      #   File.write(path, JSON.generate(some_data))
      #
      # @see CircleCI::Parallel::Configuration#before_join
      # @see CircleCI::Parallel::Configuration#after_join
      def local_data_dir
        current_node.data_dir.tap do |path|
          FileUtils.makedirs(path) unless Dir.exist?(path)
        end
      end

      # Returns the download data directory where all node data will be downloaded.
      # Note that only master node downloads data from other slave node.
      # When the downloads are complete, the directory structure on the master node will be the
      # following:
      #
      #     .
      #     ├── node0
      #     │   └── node_specific_data_you_saved_on_node0.txt
      #     ├── node1
      #     │   └── node_specific_data_you_saved_on_node1.txt
      #     └── node2
      #         └── node_specific_data_you_saved_on_node2.txt
      #
      # @return [String] the download data directory
      #
      # @example
      #   Dir.chdir(CircleCI::Parallel.download_data_dir) do
      #     merged_data = Dir['*/data.json'].each_with_object({}) do |path, merged_data|
      #       data = JSON.parse(File.read(path))
      #       node_name = File.dirname(path)
      #       merged_data[node_name] = data
      #     end
      #   end
      #
      # @see CircleCI::Parallel::Configuration#after_download
      def download_data_dir
        BASE_DATA_DIR.tap do |path|
          FileUtils.makedirs(path) unless Dir.exist?(path)
        end
      end

      # @api private
      def reset!
        environment.clean
        @environment = nil
      end

      private

      def environment
        @environment ||= Environment.new
      end
    end
  end
end
