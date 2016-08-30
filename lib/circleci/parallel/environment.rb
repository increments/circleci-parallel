require 'fileutils'
require 'circleci/parallel/build'
require 'circleci/parallel/configuration'
require 'circleci/parallel/node'
require 'circleci/parallel/task/master'
require 'circleci/parallel/task/slave'
require 'circleci/parallel/task/mock_master'
require 'circleci/parallel/task/mock_slave'

module CircleCI
  module Parallel
    # @api private
    class Environment
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield configuration
      end

      def current_build
        @current_build ||= Build.new(ENV['CIRCLE_BUILD_NUM'].to_i, ENV['CIRCLE_NODE_TOTAL'].to_i)
      end

      def current_node
        @current_node ||= Node.new(current_build, ENV['CIRCLE_NODE_INDEX'].to_i)
      end

      def join
        validate!
        task.run
      end

      def puts(*args)
        Kernel.puts(*args) unless configuration.silent
      end

      def clean
        FileUtils.rmtree(WORK_DIR) if Dir.exist?(WORK_DIR)
      end

      private

      def validate!
        raise 'The current environment is not on CircleCI.' unless ENV['CIRCLECI']

        unless ENV['CIRCLE_NODE_TOTAL']
          warn 'Environment variable CIRCLE_NODE_TOTAL is not set. ' \
               'Maybe you forgot adding `parallel: true` to your circle.yml? ' \
               'https://circleci.com/docs/parallel-manual-setup/'
        end
      end

      def task
        @task ||= task_class.new(current_node, configuration)
      end

      def task_class
        if configuration.mock_mode
          current_node.master? ? Task::MockMaster : Task::MockSlave
        else
          current_node.master? ? Task::Master : Task::Slave
        end
      end
    end
  end
end
