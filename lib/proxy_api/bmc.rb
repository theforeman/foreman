module ProxyAPI
  class BMC < ProxyAPI::Resource

    def initialize args
      @target = args[:host_ip] || '127.0.0.1'
      @url = args[:url] + "/bmc"
      super args
    end

    # gets a list of supported providers
    def providers
      parse get("providers")
    end

    # gets a list of supported providers installed on the proxy
    def providers_installed
      parse get("providers/installed")
    end

    # Perform a boot operation on the bmc device
    def boot args
      valid_boot_devices = %w[disk cdrom pxe bios]
      # valid additional arguments args[:reboot] = true|false, args[:persistent] = true|false
      #  put "/bmc/:host/chassis/config/?:function?/?:action?" do
      case args[:function]
      when "bootdevice"
        if valid_boot_devices.include?(args[:device])
          parse put(args, bmc_url_for('config',"#{args[:function]}/#{args[:device]}"))
        else
          raise NoMethodError
        end
      else
        raise NoMethodError
      end
    end

    # Perform a power operation on the bmc device
    def power args
      # get "/bmc/:host/chassis/power/:action"
      # put "/bmc/:host/chassis/power/:action"
      case args[:action]
      when "on?", "off?", "status"
        args[:action].chop! if args[:action].include?('?')
        response = parse(get(bmc_url_for('power',args[:action]), args))
        response.is_a?(Hash) ?  response['result'] : response
      when "on", "off", "cycle", "soft"
        res = parse put(args, bmc_url_for('power',args[:action]))
        # This is a simple action, just return the result of the action
        res && res['result'] == true
      else
        raise NoMethodError
      end
    end

    # perform an identify operation on the bmc device
    def identify args
      # get "/bmc/:host/chassis/identify/:action"
      # put "/bmc/:host/chassis/identify/:action"
      case args[:action]
      when "status"
        parse get(bmc_url_for('identify',args[:action]), args)
      when "on", "off"
        parse put(args, bmc_url_for('identify',args[:action]))
      else
        raise NoMethodError
      end

    end

    # perform a lan get operation on the bmc device
    def lan args
      # get "/bmc/:host/lan/:action"
      case args[:action]
      when "ip", "netmask", "mac", "gateway"
        response = parse(get(bmc_url_for('lan',args[:action]), args))
        response.is_a?(Hash) ?  response['result'] : response
      else
        raise NoMethodError
      end
    end

    private

    def bmc_url_for controller,action
      case controller
      when "lan"
        "/#{@target}/lan/#{action}"
      else
        "/#{@target}/chassis/#{controller}/#{action}"
      end
    end

    def method_missing(method, *args, &block)
      begin
        super(method, *args, &block)
      rescue NoMethodError
        margs = args.first
        farg  = method.to_s.split('_')
        # method must contain 2 parts, ie: power_on, boot_disk
        raise NoMethodError unless farg.length == 2

        case farg.first
        when "power"
          margs[:action] = farg.last
          power(margs)
        when "boot"
          margs[:function] = "bootdevice"
          margs[:device]   = farg.last
          boot(margs)
        when "identify"
          margs[:action] = farg.last
          identify(margs)
        when "lan"
          margs[:action] = farg.last
          lan(margs)
        else
          raise NoMethodError
        end
      end
    end
  end
end
