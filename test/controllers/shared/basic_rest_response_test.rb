module BasicRestResponseTest
  extend ActiveSupport::Concern

  module ClassMethods
    def basic_index_test(collection = nil)
      context 'GET #index' do
        setup { get :index, session: set_session_user }
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
        setup { get :new, session: set_session_user }
        should respond_with(:success)
        should render_template(:new)
      end
    end

    def basic_edit_test(object_found = nil)
      context 'GET #edit' do
        setup do
          get :edit, params: { :id => @model }, session: set_session_user
        end

        should respond_with(:success)
        should render_template(:edit)
        test 'assigns the found object to an instance variable' do
          object_found ||= assigns[:resource_class].to_s.tableize.singularize
          assert_equal @model, assigns(:"#{object_found}")
        end
      end
    end

    def basic_pagination_per_page_test
      context 'GET #index' do
        setup do
          @entries_per_page = Setting[:entries_per_page] || 5
          FactoryBot.create_list(get_factory_name, @entries_per_page + 2, *@factory_options)
        end

        test 'should render correct per_page value' do
          get :index, params: {per_page: @entries_per_page + 1}, session: set_session_user
          assert_response :success
          per_page_results = response.body.scan(/perPage&quot;:\d+/).first.gsub(/[^\d]/, '').to_i
          assert_equal @entries_per_page, per_page_results
        end

        test 'should render per page dropdown with correct values' do
          get :index, params: {per_page: @entries_per_page + 1}, session: set_session_user
          assert_response :success
          assert_not_nil response.body['perPageOptions&quot;:[5,10,15,20,21,25,50]']
        end

        test 'sort links should include per page param' do
          get :index, params: {per_page: @entries_per_page + 1}, session: set_session_user
          assert_response :success
          sort_links = css_select('thead a')
          sort_links.each do |link|
            assert_includes link['href'], "per_page=#{@entries_per_page + 1}"
          end
        end
      end
    end

    def all_per_page_test
      context '#index' do
        setup do
          per_page = Setting[:entries_per_page]
          resource_count = @controller.resource_class.count
          FactoryBot.create_list(get_factory_name, per_page - resource_count + 1, *@factory_options) if resource_count < per_page
        end

        test 'should render all records' do
          get :index, params: { per_page: 'all' }
          assert_response :success
          res = ActiveSupport::JSON.decode(@response.body)
          assert_equal @controller.controller_name.classify.constantize.count, res['results'].size
        end
      end
    end

    def basic_pagination_rendered_test
      context 'GET #index' do
        setup do
          @old = Setting[:entries_per_page]
          FactoryBot.create(get_factory_name, *@factory_options) if @controller.resource_class.count.zero?
          Setting[:entries_per_page] = @controller.resource_class.count
        end

        test 'should not render pagination' do
          get :index, session: set_session_user
          assert_response :success
          refute_includes @response.body, "id=pagination"
        end

        test 'should render pagination' do
          FactoryBot.create(get_factory_name, *@factory_options)
          get :index, session: set_session_user
          assert_response :success
          assert_select "div[id='pagination']"
        end

        test 'should not render pagination when no search results' do
          @request.env['HTTP_REFERER'] = root_url
          get :index, params: {search: "name='A98$bcD#67Ef*g"}, session: set_session_user
          assert (@response.body.include? "No entries found") || @response.body.match(/You are being.*redirected/)
        end

        teardown do
          Setting[:entries_per_page] = @old
        end
      end
    end
  end

  def get_factory_name
    model = @controller.controller_name.singularize
    case model
      when "subnet"
        :subnet_ipv4
      else
        model.to_sym
    end
  end
end
