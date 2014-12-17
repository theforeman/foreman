# Architectures
Architecture.without_auditing do
  Architecture.find_or_create_by(:name => "x86_64")
  Architecture.find_or_create_by(:name => "i386")
end
