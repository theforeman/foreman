# Architectures
Architecture.without_auditing do
  Architecture.where(:name => "x86_64").first_or_create
  Architecture.where(:name => "i386").first_or_create
end
