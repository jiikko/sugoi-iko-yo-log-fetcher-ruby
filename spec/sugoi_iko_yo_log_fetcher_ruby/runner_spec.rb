require 'spec_helper'

describe SugoiIkoYoLogFetcherRuby::Runner do
  describe '#download!' do
    require 'tmpdir'

    before(:each) do
      mock_s3_object_class = Struct.new(:key)
      mock_s3_object = mock_s3_object_class.new('logs/test/2015/12/12_0.gz')
      allow_any_instance_of(SugoiIkoYoLogFetcherRuby::Runner).to receive(:bucket_objects).and_return([mock_s3_object])
      allow(mock_s3_object).to receive(:get).and_return(nil)
      allow_any_instance_of(SugoiIkoYoLogFetcherRuby::Runner).to receive(:setup_aws_sdk!).and_return(nil)
    end

    context '#chdir_with を使う時' do
      it 'be success' do
        SugoiIkoYoLogFetcherRuby.chdir_with do |tmpdir|
          runner = SugoiIkoYoLogFetcherRuby::Runner.new(Date.new(2015, 11, 11))
          runner.download!
          expect(File.ftype("#{tmpdir}/logs/test/2015/12/")).to eq('directory')
          expect(File.ftype("#{tmpdir}/logs/test/2015/12/12_0.gz")).to eq('file')
        end
      end
    end

    it 'be success' do
      correct_pwd = Dir.pwd
      begin
        dir_name = Dir.mktmpdir
        Dir.chdir(dir_name)
        runner = SugoiIkoYoLogFetcherRuby::Runner.new(Date.new(2011, 1, 1))
        runner.download!
        expect(File.ftype("#{dir_name}/logs/test/2015/12/")).to eq('directory')
        expect(File.ftype("#{dir_name}/logs/test/2015/12/12_0.gz")).to eq('file')
      ensure
        Dir.chdir(correct_pwd)
        FileUtils.remove_entry_secure(dir_name) if File.exists?(dir_name)
      end
    end
  end
end
