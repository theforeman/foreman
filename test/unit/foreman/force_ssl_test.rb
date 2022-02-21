require 'test_helper'

class ForceSslTest < ActiveSupport::TestCase
  let(:params) { {} }
  let(:path) { '/general/path' }
  let(:request) { stub(path_info: path, params: params) }
  subject { Foreman::ForceSsl.new(request) }

  describe 'general urls' do
    it 'do not allow http' do
      _(subject.allows_http?).must_equal false
    end
  end

  describe 'unattended urls' do
    let(:path) { '/unattended/something' }

    context 'with http unattended_url' do
      setup do
        Setting[:unattended_url] = 'http://some.url/'
      end

      it 'allows http' do
        _(subject.allows_http?).must_equal true
      end

      context 'with preview params' do
        let(:params) { { 'spoof' => true } }

        it 'doesnt allow http for previews' do
          _(subject.allows_http?).must_equal false
        end
      end
    end

    context 'with https unattended_url' do
      setup do
        Setting[:unattended_url] = 'https://some.url/'
      end

      it 'does not allow http' do
        _(subject.allows_http?).must_equal false
      end
    end
  end
end
