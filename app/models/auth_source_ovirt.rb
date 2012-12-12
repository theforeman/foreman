class AuthSourceOvirt < AuthSource
  validates_presence_of :host, :port
  validates_length_of :host, :port, :maximum => 60, :allow_nil => false

  def authenticate(login, password)

    # oVirt passes the username with "ovirt_" prefix. We remove it in this function.
    # The login name in Foreman will include the "ovirt_" prefix, but all the other user details won't
    # The reason for this prefix is that the login source of this user will always be the oVirt Authentication source
    login = login.sub("ovirt_","")

    userDetails = get_user_details(login, password)

    return nil unless !userDetails.nil?

    # In case a field is empty, we put the login as the value
    # The oVirt login must be in the form of user@domain, so it is also valid as
    # E-mail value
    attrs = [:firstname => userDetails.has_key?('name') ? userDetails['name'] : login.split("@")[0],
             :lastname => userDetails['surname'],
             :mail => userDetails.has_key?('email') ? userDetails['email'] : login,
             :auth_source_id => self.id ]
    attrs
  end

  def auth_method_name
    "OVIRT"
  end
  alias_method :to_label, :auth_method_name

  def can_set_password?
    false
  end
  
  private

  def get_user_details(login, password)
    response = get_user_from_ovirt(login, password)
    userDetails = !response.nil? ? JSON.parse(response) : nil
    userDetails
  end    

  def get_user_from_ovirt(login, password)
    logger.debug "oVirt-Auth with User " + login
    logger.debug "oVirt host name is " + host
    logger.debug "oVirt port number is " + port.to_s()

    prefix = tls ? 'https' : 'http'
    url=prefix + '://' + host + ':' + port.to_s()

    logger.debug "oVirt URL is " + url

    # password contains the oVirt engine session ID followed ';'
    # and the guid of the user
    user_id_location = password.rindex(';')
    user_id = password[user_id_location + 1 .. password.length()]
    session_id = password[0 .. user_id_location - 1]

    session_id_escaped = Rack::Utils.escape(session_id)

    # The password we get is the REST session ID
    # We set it in the cookie, using the "Prefer" header
    # to keep the session alive
    session_id = ({ :JSESSIONID => session_id_escaped })
    headers = ({ :content_type => 'application/json',
                 :accept => 'application/json',
                 :Prefer => "persistent-auth",
                 :cookies => ( session_id )
    })

    # We query for the user, to get its details
    response = RestClient::Resource.new(url)['/api/users/' + user_id].get(headers)
    response
  end
end
