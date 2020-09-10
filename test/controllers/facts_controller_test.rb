require 'test_helper'

class FactsControllerTest < ActionController::TestCase
  describe '#show' do
    let(:fact_value) do
      FactoryBot.create(:fact_value, value: '<script>avalue</script>')
    end

    it 'doesnt escape values' do
      get :show, params: { id: fact_value.fact_name_id, format: :json }, session: set_session_user
      json = JSON.parse(response.body)
      assert_equal json['values'][0][0], fact_value.value
    end
  end
end
