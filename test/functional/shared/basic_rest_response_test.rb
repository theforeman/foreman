module BasicRestResponseTest
  extend ActiveSupport::Concern

  module ClassMethods
    def basic_index_test(collection = nil)
      context 'GET #index' do
        setup { get :index, {}, set_session_user }
        should respond_with(:success)
        should render_template(:index)
        test 'assigns a collection instance variable' do
          collection ||= assigns[:model_of_controller].to_s.tableize
          assert_not_nil assigns(:"#{collection}")
        end
      end
    end

    def basic_new_test
      context 'GET #new' do
        setup { get :new, {}, set_session_user }
        should respond_with(:success)
        should render_template(:new)
      end
    end

    def basic_edit_test(object_found = nil)
      context 'GET #edit' do
        setup do
          get :edit, { :id => @model }, set_session_user
        end

        should respond_with(:success)
        should render_template(:edit)
        test 'assigns the found object to an instance variable' do
          object_found ||= assigns[:resource_class].to_s.tableize.singularize
          assert_equal @model, assigns(:"#{object_found}")
        end
      end
    end
  end
end
