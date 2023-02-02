object @host

attributes :name, :id

node :display_name do |host|
  host.to_label
end
