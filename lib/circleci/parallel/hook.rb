module CircleCI
  module Parallel
    class Hook
      attr_reader :proc, :chdir

      def initialize(proc = nil, chdir = true)
        @proc = proc
        @chdir = chdir
      end

      def call(dir)
        return unless proc

        if chdir
          Dir.chdir(dir, &proc)
        else
          proc.call(dir)
        end
      end
    end
  end
end
