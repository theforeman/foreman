module Api
  module V1
    class OperatingsystemsController < BaseController
  
      before_filter :find_by_name, :only => %w{show edit update destroy bootfiles}

      def index
        @operatingsystems = Operatingsystem.all
      end

      def show
      end

      def create
        @operatingsystem = Operatingsystem.new(params[:operatingsystem])
        process_error unless @operatingsystem.save
     end

      def update
        process_error unless @operatingsystem.update_attributes(params[:operatingsystem])
      end

      def destroy
        process_error unless @operatingsystem.destroy
      end

      def bootfiles
        medium = Medium.find_by_name(params[:medium])
        arch =  Architecture.find_by_name(params[:architecture])
        render :json => @operatingsystem.pxe_files(medium, arch)
      rescue => e
        render :json => e.to_s, :status => :unprocessable_entity
      end

    end
  end
end
