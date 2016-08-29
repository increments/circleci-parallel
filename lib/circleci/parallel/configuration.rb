require 'circleci/parallel/hook'

module CircleCI
  module Parallel
    class Configuration
      attr_accessor :silent
      attr_reader :before_join_hook, :after_download_hook, :after_join_hook

      def initialize
        @silent = false
        @before_join_hook = @after_download_hook = @after_join_hook = Hook.new
      end

      def before_join(chdir: true, &block)
        @before_join_hook = Hook.new(block, chdir)
      end

      def after_download(chdir: true, &block)
        @after_download_hook = Hook.new(block, chdir)
      end

      def after_join(chdir: true, &block)
        @after_join_hook = Hook.new(block, chdir)
      end
    end
  end
end
