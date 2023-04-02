object false
node(:result) { "ok" }
node(:status) { 200 }
node(:version) { SETTINGS[:version].full }
node(:api_version) { 2 }
node(:remote_ip) { @remote_ip } if @remote_ip
