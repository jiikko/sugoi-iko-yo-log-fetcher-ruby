require 'sugoi_iko_yo_log_fetcher_ruby/version'
require 'date'

module SugoiIkoYoLogFetcherRuby
  class CLI
    def initialize(args = nil)
      @error_messages = []
      @start_on = args[0]
      @end_on = args[1]
    end

    def run
      if @end_on.nil?
        fetch_log(@start_on)
      end

      Date.parse(@start_on)..Date.parse(@end_on).each do |date|
        fetch_log(date)
      end
    end

    def valid?
      case
      when @start_on.nil? && @end_on.nil?
        @error_message << 'not found args.'
      when @start_on > @end_on
        @error_message << 'invalid dates. endのほうが大きく'
      else
        true
      end
    end

    def messages
      @error_messages.map { |message|
        "[ERROR] #{message}"
      }.join("\n")
    end

    private

    def fetch_log(date)
      # TODO
    end
  end

  def build_cli(argv)
    CLI.new(argv)
  end
end
