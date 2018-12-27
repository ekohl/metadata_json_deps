# metadata-json-deps

The metadata-json-deps tool validates dependencies in `metadata.json` files in Puppet modules against the latest published versions on the [Puppet Forge](https://forge.puppet.com/).

## Compatibility

metadata-json-deps is compatible with Ruby versions 2.0.0 and newer.

## Installation

via `gem` command:
``` shell
gem install metadata-json-deps
```

via Gemfile:
``` ruby
gem 'metadata-json-deps'
```

## Usage

### Testing with metadata-json-deps

On the command line, run `metadata-json-deps` with the path(s) of your `metadata.json` file(s):

```shell
metadata-json-deps /path/to/metadata.json
```

It can also be run verbosely to show valid dependencies:

```shell
metadata-json-deps -v modules/*/metadata.json
```

### Testing with metadata-json-deps as a Rake task

You can also integrate `metadata-json-deps` checks into your tests using a Rake task:

```ruby
require 'metadata_json_deps'
task :metadata_deps do
  files = FileList['modules/*/metadata.json']
  PuppetMetadataChecker::Runner.run(files)
end
```
