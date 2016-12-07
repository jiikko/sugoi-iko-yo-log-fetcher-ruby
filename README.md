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
認証情報は `~/.ai_s3log` に用意します
```shell
$ cat ~/.ai_s3log
access_token
secret_toten
```

### shell
```shell
$ sugoi-iko-yo-log-fetcher-ruby start end
```

### ruby
```ruby
require "bundler/setup"
require "sugoi_iko_yo_log_fetcher_ruby"

SugoiIkoYoLogFetcherRuby.chdir_with do |tmpdir|
  runner = SugoiIkoYoLogFetcherRuby::Runner.new(Date.new(2015, 11, 11))
  runner.download!
  Dir.glob("#{tmpdir}/**"} do |path|
    puts path # 何らかの処理
  end
end
```

## TODO
* Glacier行きもダウンロードする
* プログレスバー
