# Architectures
Architecture.without_auditing do
  Architecture.where(:name => "x86_64").first_or_create
end
