collection @fact_values

@hash_fact_values.keys.each do |key|
	attribute key.to_sym
end