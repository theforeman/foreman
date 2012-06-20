module Api
  module V1
    class ArchitecturesController < BaseController
      include Foreman::Controller::AutoCompleteSearch
      before_filter :find_by_name, :only => %w{show update destroy}

      def index
        @architectures = Architecture.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page], :include => :operatingsystems)
      end

      def show
      end

      def create
        respond_with Architecture.new(params[:architecture])
      end

      def update
        respond_with @architecture.update_attributes(params[:architecture])
      end

      def destroy
        respond_with @architecture.destroy
      end
    end
  end
end
