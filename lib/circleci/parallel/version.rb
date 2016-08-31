module CircleCI
  module Parallel
    module Version
      MAJOR = 0
      MINOR = 4
      PATCH = 1

      def self.to_s
        [MAJOR, MINOR, PATCH].join('.')
      end
    end
  end
end
