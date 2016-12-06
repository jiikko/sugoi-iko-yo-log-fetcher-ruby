# sugoi-iko-yo-log-fetcher-ruby
* Amazon S3に保管されているログデータを並列でダウンロードする
* https://github.com/actindi-dev/sugoi-iko-yo-log-fetcher のRuby実装です

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sugoi-iko-yo-log-fetcher-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sugoi-iko-yo-log-fetcher-ruby

## Usage
### shell
```shell
$ sugoi-iko-yo-log-fetcher-ruby start end
```

### ruby
```ruby
require 'fileutils'
require 'tmpdir'

prev_pwd = Dir.pwd
dir_name = Dir.mktmpdir
Dir.chdir(dir_name) # 現在のパスにログをダウンロードするのでディレクトリを移動する
runner = SugoiIkoYoLogFetcherRuby::Runner.new(Date.new(2015, 11, 11))
runner.download!
Dir.glob("#{dir_name}/**"} do |path|
  puts path # 何らかの処理
end
Dir.chdir(prev_pwd) #
FileUtils.remove_entry_secure(dir_name)
```

## TODO
* Glacier行きもダウンロードする
