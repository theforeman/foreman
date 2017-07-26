object @auth_source_external

extends "api/v2/auth_source_external/base"

node :success do
  locals[:success]
end
node :message do
  locals[:message]
end
