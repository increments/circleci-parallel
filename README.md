# CircleCI::Parallel

**CircleCI::Parallel** provides simple APIs for joining [CircleCI parallel nodes](https://circleci.com/docs/parallelism/)
and sharing files between the nodes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'circleci-parallel'
```

And then execute:

```
$ bundle install
```

## Basic Usage

Before using CircleCI::Parallel:

* [Add `parallel: true`](https://circleci.com/docs/parallel-manual-setup/)
  to the command that you'll use CircleCI::Parallel in your `circle.yml`.
* [Set up parallelism](https://circleci.com/docs/setting-up-parallelism/)
  for your project from the CircleCI web console.

CircleCI::Parallel uses SSH for joining and transferring data between nodes.

```yaml
# circle.yml
test:
  override:
    - ruby test.rb:
        parallel: true
```

```ruby
# test.rb
require 'circleci/parallel'

merged_data = {}

CircleCI::Parallel.configure do |config|
  # This hook will be invoked on all the nodes.
  # The current working directory in this hook is set to the local data directory
  # where node specific data should be saved in.
  config.before_join do
    data = do_something
    json = JSON.generate(data)
    File.write('data.json', json)
  end

  # This hook will be invoked only on the master node after downloading all data from slave nodes.
  # The current working directory in this hook is set to the download data directory
  # where all node data are gathered into.
  # The directory structure on the master node will be the following:
  #
  #     .
  #     ├── node0
  #     │   └── node_specific_data_you_saved_on_node0.txt
  #     ├── node1
  #     │   └── node_specific_data_you_saved_on_node1.txt
  #     └── node2
  #         └── node_specific_data_you_saved_on_node2.txt
  config.after_download do
    Dir.glob('*/data.json') do |path|
      json = File.read(path)
      data = JSON.parse(json)
      node_name = File.dirname(path)
      merged_data[node_name] = data
    end
  end
end

# Join all nodes in the same build and gather all node data into the master node.
# Invoking this method blocks until the join and data downloads are complete.
CircleCI::Parallel.join

p merged_data
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
