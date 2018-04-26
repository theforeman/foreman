module Api
  module V2
    class PuppetcaTokenController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::SmartProxyAuth

      add_smart_proxy_filters :destroy, :features => ['Puppet CA']

      api :DELETE, "/puppetca_token/:value", N_('Verify CSRs by deleting their tokens should they exist')
      param :value, String, :required => true

      def destroy
        token = Token::Puppetca.find_by(:value => params[:id])
        if token.blank? || !token.host.build?
          render_error('not_found', status: 404)
        else
          token.delete
          render :json => {}, status: :no_content
        end
      end
    end
  end
end
