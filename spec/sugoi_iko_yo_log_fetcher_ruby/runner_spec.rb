require 'spec_helper'

describe SugoiIkoYoLogFetcherRuby::Runner do
  describe '#download!' do
    context '日付が期間' do
      before(:each) do
        s3_mock_object_class = Struct.new(:key)
        mock_list = [
          s3_mock_object_class.new('logs/test/2015/12/12_0.gz'),
          s3_mock_object_class.new('logs/test/2015/12/13_0.gz'),
          s3_mock_object_class.new('logs/test/2015/12/14_1.gz'),
        ]
        allow_any_instance_of(SugoiIkoYoLogFetcherRuby::Runner).to \
          receive(:bucket_objects).with(prefix: 'logs/app/2015/11/12').and_return([mock_list[0]])
        allow_any_instance_of(SugoiIkoYoLogFetcherRuby::Runner).to \
          receive(:bucket_objects).with(prefix: 'logs/app/2015/11/13').and_return([mock_list[1]])
        allow_any_instance_of(SugoiIkoYoLogFetcherRuby::Runner).to \
          receive(:bucket_objects).with(prefix: 'logs/app/2015/11/14').and_return([mock_list[2]])
        mock_list.each do |s3_mock_object|
          allow(s3_mock_object).to receive(:get).and_return(nil)
        end
        allow_any_instance_of(SugoiIkoYoLogFetcherRuby::Runner).to receive(:setup_aws_sdk!).and_return(nil)
      end

      it 'be success' do
        SugoiIkoYoLogFetcherRuby.chdir_with do |tmpdir|
          runner = SugoiIkoYoLogFetcherRuby::Runner.new(Date.new(2015, 11, 12), Date.new(2015, 11, 14))
          runner.download!
          expect(File.ftype("#{tmpdir}/logs/test/2015/12/")).to eq('directory')
          expect(File.ftype("#{tmpdir}/logs/test/2015/12/12_0.gz")).to eq('file')
        end
      end
    end

    context '日付が1日' do
      before(:each) do
        s3_mock_object_class = Struct.new(:key)
        s3_mock_object = s3_mock_object_class.new('logs/test/2015/12/12_0.gz')
        allow_any_instance_of(SugoiIkoYoLogFetcherRuby::Runner).to \
          receive(:bucket_objects).and_return([s3_mock_object])
        allow(s3_mock_object).to receive(:get).and_return(nil)
        allow_any_instance_of(SugoiIkoYoLogFetcherRuby::Runner).to \
          receive(:setup_aws_sdk!).and_return(nil)
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

      context 'except_paths オプションがある時' do
        it 'except_paths に含むパスはdownloadをしないこと' do
          SugoiIkoYoLogFetcherRuby.chdir_with do |tmpdir|
            runner = SugoiIkoYoLogFetcherRuby::Runner.new(Date.new(2015, 11, 11))
            runner.download!(except_paths: ['logs/test/2015/12/12_0.gz'])
            expect(File.ftype("#{tmpdir}/logs/test/2015/12/")).to eq('directory')
            expect(Dir.glob("#{tmpdir}/logs/test/2015/12/*").size).to eq(0)
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
          expect(Dir.glob("#{dir_name}/logs/test/2015/12/*").size).to eq(1)
        ensure
          Dir.chdir(correct_pwd)
          FileUtils.remove_entry_secure(dir_name) if File.exists?(dir_name)
        end
      end
    end
  end
end
