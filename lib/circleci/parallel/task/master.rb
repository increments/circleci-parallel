require 'circleci/parallel/task/base'

module CircleCI
  module Parallel
    module Task
      # @api private
      class Master < Base
        def run
          create_node_data_dir
          configuration.before_join_hook.call(node.data_dir)
          mark_as_joining
          download_from_slave_nodes
          configuration.after_download_hook.call(BASE_DATA_DIR)
          configuration.after_join_hook.call(node.data_dir)
          done
        end

        private

        def download_from_slave_nodes
          # TODO: Consider implementing timeout mechanism
          Parallel.puts('Waiting for slave nodes to be ready for download...')
          loop do
            downloaders.each(&:download)
            break if downloaders.all?(&:downloaded?)
            Kernel.sleep(1)
          end
        end

        def downloaders
          @downloaders ||= node.other_nodes.map { |other_node| Downloader.new(other_node) }
        end

        Downloader = Struct.new(:node) do
          def ready_for_download?
            Kernel.system('ssh', node.ssh_host, 'test', '-f', JOIN_MARKER_FILE)
          end

          def download
            return if downloaded?
            return unless ready_for_download?
            Parallel.puts("Downloading data from #{node.ssh_host}...")
            @downloaded = scp
            mark_as_downloaded if downloaded?
          end

          def scp
            Kernel.system('scp', '-q', '-r', "#{node.ssh_host}:#{node.data_dir}", BASE_DATA_DIR)
          end

          def downloaded?
            @downloaded
          end

          def mark_as_downloaded
            Kernel.system('ssh', node.ssh_host, 'touch', DOWNLOAD_MARKER_FILE)
          end
        end
      end
    end
  end
end
