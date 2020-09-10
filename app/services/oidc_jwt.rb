class OidcJwt < JwtToken
  def decode
    return if token.blank?
    OidcJwtValidate.new(token).decoded_payload
  end
end
