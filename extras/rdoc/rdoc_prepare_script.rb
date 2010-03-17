#!/usr/bin/ruby
require 'fileutils'
# Takes a list of directories and copies them, ignoring version control directories, to a new location
# It then sanitizes them by removing any circular symlinks
# It must return the new root directory for the tree 
modules_root = "/tmp/puppet"
FileUtils.mkpath modules_root unless File.exist? modules_root
FileUtils.rm_rf Dir.glob("#{modules_root}/*")
FileUtils.chdir "/"
dirs = ARGV[0..100]

# We  need to copy in the checked out puppet modules tree. Skipping all the .svn entries.
modules = "/etc/puppet/modules"
exit -1 unless system "tar --create --file - --exclude-vcs #{modules[1..-1]} | tar --extract --file - --read-full-records --directory #{modules_root}"

# This copies in the /etc/puppent/env directory symlink trees
exit -1 unless system "tar --create --file - --exclude-vcs #{dirs.map{|d| d[1..-1]}.join(" ")} | tar --extract --file - --read-full-records --directory #{modules_root}"
for dir in dirs
  here = modules_root + dir 
  # Scan each modulepath for symlinks and remove them if they point at ".". 
  # If they are absolute, recreate them pointing at the copied tree location  
  Dir.foreach(here) do |entry|
    linkfile = here + "/" + entry
    next unless File.ftype(linkfile) == "link"
    target = File.readlink(linkfile)
    File.unlink(linkfile) if target == "."
    if target=~/^\//
      File.unlink(linkfile)
      File.symlink modules_root + target, linkfile
    end
  end
end
# Look through the resulting tree ans remove broken and cyclic links
links =  `find #{modules_root} -type l`
for link in links
  link.chomp!
  # Remove links pointing to missing files
  unless File.exist?(File.readlink(link))
    File.unlink(link) 
    next
  end
  # Remove links pointing to "." 
  File.unlink(link) if File.readlink(link) == "."
end
puts modules_root
