module FogExtensions
  module Debug
    class DebugHttpInstrumentor
      class << self
        attr_accessor :events

        def instrument(name, params = {}, &block)
          logger = ::Foreman::Logging.logger('crs')
          if logger.debug?
            begin
              params = params.dup
              if params.key?(:headers) && params[:headers].key?('Authorization')
                params[:headers] = params[:headers].dup
                params[:headers]['Authorization'] = 'FILTERED'
              end
              if params.key?(:password)
                params[:password] = 'FILTERED'
              end
              logger.debug("--- #{name} ---")
              if name.include?('.request')
                query = ''
                tmp_query = ''
                if params.key?(:query) && !params[:query].nil?
                  params[:query].each do |key, value|
                    tmp_query += "#{key}=#{value}&"
                  end
                  if !tmp_query.nil?
                    query = "?#{tmp_query}"
                    query.chomp!('&')
                  end
                end
                logger.debug("#{params[:method]} #{params[:path]}#{query} HTTP/1.1" )
                logger.debug("User-Agent: #{params[:headers]['User-Agent']}")
                logger.debug("Host: #{params[:host]} Port: #{params[:port]}")
                logger.debug("Accept: #{params[:headers]['Accept']}")
                logger.debug("X-Auth-Token: #{params[:headers]['X-Auth-Token']}")
                logger.debug("Body: #{params[:body]}")
              elsif name.include?('.response')
                logger.debug("HTTP/1.1 #{params[:status]}")
                logger.debug("Content-Length: #{params[:headers]['Content-Length']}")
                logger.debug("Content-Type: #{params[:headers]['Content-Type']}")
                logger.debug("Date: #{params[:headers]['Date']}")
                params[:headers].each do |key, value|
                  if !['Content-Length', 'Content-Type', 'Date'].include?(key)
                    logger.debug("#{key}: #{value}")
                  end
                end
                logger.debug("Date: #{params[:headers]['Date']}\n")
                logger.debug("Body: #{params[:body]}")
              elsif name.include?('.retry')
                logger.debug("#{params.inspect}")
              elsif name.include?('.error')
                logger.debug("#{params.inspect}")
              end
            rescue => e
              logger.debug("Error during fog debug instrumentation: #{e}")
            end
          end

          if block_given?
            yield
          end
        end
      end
    end
  end
end
