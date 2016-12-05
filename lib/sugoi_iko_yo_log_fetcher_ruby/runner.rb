module SugoiIkoYoLogFetcherRuby
  class Runner
    def initialize(*dates)
      setup_aws_sdk!
      @dates = dates
    end

    # 指定したパスにダウンロードをする
    def direct_download!
      Parallel.each(@dates, in_threads: 5)  do |date|
        file = date_to_local_path(date)
        fetch_file(file, date)
      end
      true
    end

    # tempfileにダウンロードするので受取側はcpした後にtempfileのcloseをしてくれ
    def paths
      Parallel.map(@dates, in_threads: 5)  do |date|
        file = Tempfile.new
        fetch_file(file, date)
        file.seek(0)
        file
      end
    end

    private

    def fetch_file(file, date)
      file.write(s3_object(date))
    end

    def s3_object(date)
      s3 = Aws::S3::Client.new
      s3.get_object(bucket: iko_yo_log_bucket_name, key: date2key(date))
    end

    def date_to_key(date)
      # TODO
    end

    # TODO
    def date_to_local_path(date)
      path = File.join("#{prefix}", '')
      File.new(path)
    end

    def iko_yo_log_bucket_name
      'iko-yo'
    end

    def setup_aws_sdk!
      Aws.config.update({
        region: 'us-west-2',
        # credentials: Aws::Credentials.new('akid', 'secret')
      })
    end
  end
end
