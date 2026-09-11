object @auth_source_oidc

extends 'api/v2/auth_source_oidcs/base'

node :success do
  locals[:success]
end

node :message do
  locals[:message]
end
