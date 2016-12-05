require 'spec_helper'

describe SugoiIkoYoLogFetcherRuby::Runner do
  describe '#paths' do
    it 'TempFileインスタンスが返ってくること' do
      allow_any_instance_of(SugoiIkoYoLogFetcherRuby::Runner).to receive(:fetch_file).and_return(nil)
      runner = SugoiIkoYoLogFetcherRuby::Runner.new(Date.new(2011, 1, 1))
      expect(runner.files.count).to eq(1)
      expect(runner.files.first).to be_a(Tempfile)
    end
  end
end
