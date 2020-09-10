object false

node(:message) { _("Media type in 'Content-Type: %s' is unsupported in API v2 for POST and PUT requests. Please use 'Content-Type: application/json'.") % request.content_type }
