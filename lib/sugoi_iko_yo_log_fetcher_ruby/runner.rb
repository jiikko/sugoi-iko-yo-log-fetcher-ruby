require 'fileutils'
require 'thread'

module SugoiIkoYoLogFetcherRuby
  class Runner
    def initialize(*dates)
      setup_aws_sdk!
      @dates =
        if dates.size == 1
          dates
        else
          (dates[0]..dates[1]).to_a
        end
    end

    def download!
      mutex = Mutex.new
      file_list = each_dates do |date|
        Parallel.map(bucket_objects(prefix: date_to_prefix_key(date)), in_threads: 5) do |object|
          mutex.synchronize { puts "found #{object.key}" }
          dir_path = File.join('./', dir_of(object.key))
          FileUtils.mkdir_p(dir_path) unless File.exists?(dir_path)
          unless File.exists?(object.key)
            File.open(object.key, 'w') do |file|
              object.get(response_target: file.path)
            end
            mutex.synchronize { puts "downloaded #{object.key}" }
          end
          object.key
        end
      end
      puts
      puts %(zgrep "REGEX" #{file_list.flatten.map {|x| %("#{x}") }.join(' ')})
    end

    private

    def each_dates
      if @dates.size == 1
        @dates.map do |date|
          yield(date)
        end
      else
        Parallel.map(@dates, in_threads: 2) do |date|
          yield(date)
        end
      end
    end

    def dir_of(path)
      %r!^(.+)/[^/]+$! =~ path
      $1
    end

    def bucket_objects(prefix: )
      s3 = Aws::S3::Resource.new
      bucket = s3.bucket(iko_yo_log_bucket_name)
      bucket.objects(prefix: prefix)
    end

    def date_to_prefix_key(date)
      File.join("logs/app", date.strftime('%Y/%m/%d'))
    end

    def iko_yo_log_bucket_name
      'iko-yo.net'
    end

    def setup_aws_sdk!
      secrets = File.open("#{Dir.home}/.ai_s3log").each_line.inject([]) { |a, v| a << v.chomp }
      Aws.config.update({
        region: 'ap-northeast-1',
        credentials: Aws::Credentials.new(secrets[0], secrets[1])
      })
    end
  end
end
