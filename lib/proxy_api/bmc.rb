module ProxyAPI
  class BMC < ProxyAPI::Resource
    SUPPORTED_BOOT_DEVICES = %w[disk cdrom pxe bios]

    def initialize(args)
      @target = args[:host_ip] || '127.0.0.1'
      @url = args[:url] + "/bmc"
      @provider = args[:bmc_provider]
      super args
    end

    # gets a list of supported providers
    def providers
      parse get("providers")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to get BMC providers"))
    end

    # gets a list of supported providers installed on the proxy
    def providers_installed
      parse get("providers/installed")
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to get installed BMC providers"))
    end

    # Perform a boot operation on the bmc device
    def boot(args)
      # valid additional arguments args[:reboot] = true|false, args[:persistent] = true|false
      #  put "/bmc/:host/chassis/config/?:function?/?:action?" do
      case args[:function]
      when "bootdevice"
        if SUPPORTED_BOOT_DEVICES.include?(args[:device])
          args[:bmc_provider] = @provider
          parse put(args, bmc_url_for('config', "#{args[:function]}/#{args[:device]}"))
        else
          raise NoMethodError
        end
      else
        raise NoMethodError
      end
    rescue NoMethodError => e
      raise e
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to perform boot BMC operation"))
    end

    # Perform a power operation on the bmc device
    def power(args)
      # get "/bmc/:host/chassis/power/:action"
      # put "/bmc/:host/chassis/power/:action"
      case args[:action]
      when "on?", "off?", "status"
        args[:action].chop! if args[:action].include?('?')
        provider_query = @provider ? "?bmc_provider=#{@provider}" : ''
        response = parse(get(bmc_url_for('power', args[:action]) + provider_query, args))
        response.is_a?(Hash) ? response['result'] : response
      when "on", "off", "cycle", "soft"
        args[:bmc_provider] = @provider
        res = parse put(args, bmc_url_for('power', args[:action]))
        res && (res['result'] == true || res['result'] == "#{@target}: ok\n")
      else
        raise NoMethodError
      end
    rescue NoMethodError => e
      raise e
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to perform power BMC operation"))
    end

    # perform an identify operation on the bmc device
    def identify(args)
      # get "/bmc/:host/chassis/identify/:action"
      # put "/bmc/:host/chassis/identify/:action"
      case args[:action]
      when "status"
        provider_query = @provider ? "?bmc_provider=#{@provider}" : ''
        parse get(bmc_url_for('identify', args[:action]) + provider_query, args)
      when "on", "off"
        args[:bmc_provider] = @provider
        parse put(args, bmc_url_for('identify', args[:action]))
      else
        raise NoMethodError
      end
    rescue NoMethodError => e
      raise e
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to perform identify BMC operation"))
    end

    # perform a lan get operation on the bmc device
    def lan(args)
      # get "/bmc/:host/lan/:action"
      case args[:action]
      when "ip", "netmask", "mac", "gateway"
        provider_query = @provider ? "?bmc_provider=#{@provider}" : ''
        response = parse(get(bmc_url_for('lan', args[:action]), args) + provider_query)
        response.is_a?(Hash) ? response['result'] : response
      else
        raise NoMethodError
      end
    rescue NoMethodError => e
      raise e
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to perform lan BMC operation"))
    end

    private

    def bmc_url_for(controller, action)
      case controller
      when "lan"
        "/#{@target}/lan/#{action}"
      else
        "/#{@target}/chassis/#{controller}/#{action}"
      end
    end

    def method_missing(method, *args, &block)
      if method.to_s.starts_with?('power_', 'boot_', 'identify_', 'lan_')
        margs = args.first
        farg  = method.to_s.split('_')
        # method must contain 2 parts, ie: power_on, boot_disk
        raise NoMethodError unless farg.length == 2

        case farg.first
        when 'power'
          margs[:action] = farg.last
          power(margs)
        when 'boot'
          margs[:function] = 'bootdevice'
          margs[:device]   = farg.last
          boot(margs)
        when 'identify'
          margs[:action] = farg.last
          identify(margs)
        when 'lan'
          margs[:action] = farg.last
          lan(margs)
        end
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      method.to_s.starts_with?('power_', 'boot_', 'identify_', 'lan_') || super
    end
  end
end
