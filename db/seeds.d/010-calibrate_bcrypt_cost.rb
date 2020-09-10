# calibrate default cost to be at least 50ms (performance-wise safe)
new_cost = BCrypt::Engine.calibrate(50)

# keep minimum reasonable cost in case CPU was busy
new_cost = 5 if new_cost < 5

# and set it if it's higher than current cost
current_cost = Setting[:bcrypt_cost]
if current_cost.nil? || current_cost < new_cost
  Setting[:bcrypt_cost] = new_cost
end
