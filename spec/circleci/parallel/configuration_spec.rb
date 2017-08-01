module CircleCI::Parallel
  RSpec.describe Configuration do
    subject(:config) do
      Configuration.new
    end

    describe '#on_every_node' do
      it 'allows users to configure before_sync hook on every node' do
        expect { config.on_every_node.before_sync {} }
          .to change { config.master_node_configuration.before_sync_hook }
          .and change { config.slave_node_configuration.before_sync_hook }
      end

      it 'allows users to configure after_sync hook on every node' do
        expect { config.on_every_node.after_sync {} }
          .to change { config.master_node_configuration.after_sync_hook }
          .and change { config.slave_node_configuration.after_sync_hook }
      end
    end

    describe '#on_master_node' do
      it 'allows users to configure before_sync hook on the master node' do
        expect { config.on_master_node.before_sync {} }
          .to change { config.master_node_configuration.before_sync_hook }
          .and not_change { config.slave_node_configuration.before_sync_hook }
      end

      it 'allows users to configure before_download hook on the master node' do
        expect { config.on_master_node.before_download {} }
          .to change { config.master_node_configuration.before_download_hook }
      end

      it 'allows users to configure after_download hook on the master node' do
        expect { config.on_master_node.after_download {} }
          .to change { config.master_node_configuration.after_download_hook }
      end

      it 'allows users to configure after_sync hook on the master node' do
        expect { config.on_master_node.after_sync {} }
          .to change { config.master_node_configuration.after_sync_hook }
          .and not_change { config.slave_node_configuration.after_sync_hook }
      end
    end

    describe '#on_each_slave_node' do
      it 'allows users to configure before_sync hook on each slave node' do
        expect { config.on_each_slave_node.before_sync {} }
          .to change { config.slave_node_configuration.before_sync_hook }
          .and not_change { config.master_node_configuration.before_sync_hook }
      end

      it 'allows users to configure after_sync hook on each slave node' do
        expect { config.on_each_slave_node.after_sync {} }
          .to change { config.slave_node_configuration.after_sync_hook }
          .and not_change { config.master_node_configuration.after_sync_hook }
      end
    end

    describe '#before_join' do
      it 'is supported for backward compatibility' do
        expect { config.before_join {} }
          .to change { config.master_node_configuration.before_sync_hook }
          .and change { config.slave_node_configuration.before_sync_hook }
      end
    end

    describe '#after_join' do
      it 'is supported for backward compatibility' do
        expect { config.after_join {} }
          .to change { config.master_node_configuration.after_sync_hook }
          .and change { config.slave_node_configuration.after_sync_hook }
      end
    end

    describe '#after_download' do
      it 'is supported for backward compatibility' do
        expect { config.after_download {} }
          .to change { config.master_node_configuration.after_download_hook }
      end
    end
  end
end
