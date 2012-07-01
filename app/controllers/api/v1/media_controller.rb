module Api
  module V1
    class MediaController < BaseController
      include Foreman::Controller::AutoCompleteSearch
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/media/", "List all media."
      def index
        @media = Medium.search_for(params[:search], :order => params[:order])
      end

      api :GET, "/media/:id/", "Show a medium."
      def show

      end

      def new
        @medium = Medium.new
      end

      api :POST, "/medium/", "Create a medium."
      def create
        @medium = Medium.new(params[:medium])
        process_response @medium.save
      end

      api :PUT, "/media/:id/", "Update a medium."
      def update
        process_response @medium.update_attributes(params[:medium])
      end

      api :DELETE, "/media/:id/", "Delete a medium."
      def destroy
        process_response @medium.destroy
      end

    end
  end
end
