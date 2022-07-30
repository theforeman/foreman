require 'test_helper'

class ForceSslTest < ActiveSupport::TestCase
  let(:params) { {} }
  let(:path) { '/general/path' }
  let(:request) { stub(path_info: path, params: params) }
  subject { Foreman::ForceSsl.new(request) }

  describe 'general urls' do
    it 'do not allow http' do
      refute subject.allows_http?
    end
  end

  describe 'unattended urls' do
    let(:path) { '/unattended/something' }

    context 'with http unattended_url' do
      setup do
        Setting[:unattended_url] = 'http://some.url/'
      end

      it 'allows http' do
        assert subject.allows_http?
      end

      context 'with preview params' do
        let(:params) { { 'spoof' => true } }

        it 'doesnt allow http for previews' do
          refute subject.allows_http?
        end
      end
    end

    context 'with https unattended_url' do
      setup do
        Setting[:unattended_url] = 'https://some.url/'
      end

      it 'does not allow http' do
        refute subject.allows_http?
      end
    end
  end
end
