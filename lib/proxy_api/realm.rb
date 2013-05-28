module ProxyAPI
  class Realm < Resource

    def initialize args
      @url  = "#{args[:url]}/realm/#{args[:realm_name]}"
      super args
    end

    # Creates a Realm Host entry
    # [+args+] : Hash containing at a minimum :hostname
    # Returns  : JSON Result
    def create args
      parse(post(args, ""))
    end

    # Deletes a Realm Host entry
    # [+key+] : String containing the hostname
    # Returns : Boolean status
    def delete key
      parse(super(key))
    rescue 
      # maybe the entry was already deleted
      true
    end
  end
end
