require 'fileutils'
require 'forwardable'
require 'circleci/parallel/environment'

module CircleCI
  module Parallel
    extend SingleForwardable

    def_delegators :environment,
                   :configuration, :configure, :current_build, :current_node, :join, :puts

    WORK_DIR = '/tmp/circleci-parallel'.freeze
    BASE_DATA_DIR = File.join(WORK_DIR, 'data')
    JOIN_MARKER_FILE = File.join(WORK_DIR, 'JOINING')
    DOWNLOAD_MARKER_FILE = File.join(WORK_DIR, 'DOWNLOADED')

    class << self
      def local_data_dir
        current_node.data_dir.tap do |path|
          FileUtils.makedirs(path) unless Dir.exist?(path)
        end
      end

      def download_data_dir
        BASE_DATA_DIR.tap do |path|
          FileUtils.makedirs(path) unless Dir.exist?(path)
        end
      end

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
