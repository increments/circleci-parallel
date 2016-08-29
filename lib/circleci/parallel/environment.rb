require 'fileutils'
require 'circleci/parallel/build'
require 'circleci/parallel/configuration'
require 'circleci/parallel/node'
require 'circleci/parallel/task/master'
require 'circleci/parallel/task/slave'

module CircleCI
  module Parallel
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

      def validate!
        raise 'The current environment is not on CircleCI.' unless ENV['CIRCLECI']

        unless ENV['CIRCLE_NODE_TOTAL']
          warn 'Environment variable CIRCLE_NODE_TOTAL is not set. ' \
               'Maybe you forgot adding `parallel: true` to your circle.yml? ' \
               'https://circleci.com/docs/parallel-manual-setup/'
        end
      end

      def puts(*args)
        Kernel.puts(*args) unless configuration.silent
      end

      def clean
        FileUtils.rmtree(WORK_DIR) if Dir.exist?(WORK_DIR)
      end

      private

      def task
        @task ||= begin
          task_class = current_node.master? ? Task::Master : Task::Slave
          task_class.new(current_node, configuration)
        end
      end
    end
  end
end
