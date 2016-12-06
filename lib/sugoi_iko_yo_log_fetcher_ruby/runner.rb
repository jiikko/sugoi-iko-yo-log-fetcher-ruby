require 'fileutils'

module SugoiIkoYoLogFetcherRuby
  class Runner
    def initialize(*dates)
      setup_aws_sdk!
      @dates = dates
    end

    # 指定したパスにダウンロードをする
    def download!
      each_dates do |date|
        Parallel.map(bucket_objects(prefix: date_to_prefix_key(date)), in_threads: 5) do |object|
          dir_path = File.join('./', dir_of(object.key))
          FileUtils.mkdir_p(dir_path) unless File.exists?(dir_path)
          file = File.open(object.key, 'w')
          object.get(response_target: file.path)
        end
      end
    end

    private

    def each_dates
      if @dates.size == 1
        @dates.map do |date|
          yield(date)
        end
      else
        Parallel.map(@dates, in_threads: 5) do |date|
          yield(date)
        end
      end
    end

    def dir_of(path)
      %r!^(.+)/[^/]+$! =~ path
      $1
    end

    def bucket_objects(prefix: )
      s3 = Aws::S3::Client.new
      bucket = s3.bucket(iko_yo_log_bucket_name)
      bucket.objects(prefix: prefix)
    end

    def date_to_prefix_key(date)
      File.join("./logs/app", date.strftime('%Y/%m/%d'))
    end

    def iko_yo_log_bucket_name
      'iko-yo'
    end

    # TODO
    def setup_aws_sdk!
      creds = JSON.load(File.read('secrets.json'))
      Aws.config.update({
        region: 'ap-northeast-1',
        credentials: Aws::Credentials.new(creds['AccessKeyId'], creds['SecretAccessKey'])
      })
    end
  end
end
