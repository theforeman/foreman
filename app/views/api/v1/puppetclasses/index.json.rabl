object @puppetclasses

@hash_puppetclasses.keys.each do |key|
	attribute key.to_sym
end
