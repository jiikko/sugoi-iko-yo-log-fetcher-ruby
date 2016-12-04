require 'spec_helper'

describe SugoiIkoYoLogFetcherRuby do
  it 'has a version number' do
    expect(SugoiIkoYoLogFetcherRuby::VERSION).not_to be nil
  end

  describe SugoiIkoYoLogFetcherRuby::CLI do
    describe '#valid?' do
      context '配列が1要素のとき' do
        it 'true を返す' do
          cli = SugoiIkoYoLogFetcherRuby.build_cli(['2011-11-11'])
          expect(cli.valid?).to eq true
        end
      end
      context '配列が2要素のとき' do
        context 'start == end のとき' do
          it 'true を返す' do
            cli = SugoiIkoYoLogFetcherRuby.build_cli(['2011-11-11', '2011-11-11'])
            expect(cli.valid?).to eq true
          end
        end
        context 'start > end のとき' do
          it 'false を返す' do
            cli = SugoiIkoYoLogFetcherRuby.build_cli(['2011-11-11', '2011-11-10'])
            expect(cli.valid?).to eq false
          end
        end
        context 'start < end のとき' do
          it 'true を返す' do
            cli = SugoiIkoYoLogFetcherRuby.build_cli(['2011-11-11', '2011-11-12'])
            expect(cli.valid?).to eq true
          end
        end
      end
      context '空配列のとき' do
        it 'false を返す' do
          cli = SugoiIkoYoLogFetcherRuby.build_cli([])
          expect(cli.valid?).to eq false
          expect(cli.message).to be_a String
        end
      end
    end
  end
end

