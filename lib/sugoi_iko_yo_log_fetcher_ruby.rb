require 'sugoi_iko_yo_log_fetcher_ruby/version'
require 'sugoi_iko_yo_log_fetcher_ruby/runner'
require 'date'
require 'tempfile'
require 'parallel'
require 'aws-sdk'

module SugoiIkoYoLogFetcherRuby
  class CLI
    def initialize(args = nil)
      @error_messages = []
      @start_on = args[0]
      @end_on = args[1]
    end

    def run
      runner = Runner.new
      if @end_on.nil?
        Runner.new(@start_on)
      else
        Runner.new(*Date.parse(@start_on)..Date.parse(@end_on).to_a)
      end
    end

    def valid?
      case
      when @start_on.nil?
        @error_messages << 'not found args.'
        false
      when @end_on && (@start_on > @end_on)
        @error_messages << 'invalid dates. endのほうを大きく'
        false
      else
        true
      end
    end

    def message
      @error_messages.map { |message|
        "[ERROR] #{message}"
      }.join("\n")
    end
  end

  def self.build_cli(argv)
    CLI.new(argv)
  end

  # 現在のパスにログをダウンロードするのでディレクトリを移動する
  def self.chdir_with(&block)
    correct_pwd = Dir.pwd
    tmpdir = Dir.mktmpdir
    Dir.chdir(tmpdir)
    yield(tmpdir)
  ensure
    Dir.chdir(correct_pwd)
    FileUtils.remove_entry_secure(tmpdir)
  end
end
