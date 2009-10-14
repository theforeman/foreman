# common/manifests/defines/line.pp -- a trivial mechanism to ensure a line exists in a file
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# Usage:
# line { description:
#   file => "filename",
#   line => "content",
#   ensure => {absent,*present*}
# }
#

define myline($file, $line, $ensure = 'present') {
  case $ensure {
    default : { err ( "unknown ensure value '${ensure}'" ) }
    present: {
      exec { "echo '${line}' >> '${file}'":
        unless => "grep -qFx '${line}' '${file}'",
        user => root,
      }
    }
    absent: {
      exec { "perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
        onlyif => "grep -qFx '${line}' '${file}'",
        user => root,
      }
    }
  }
}
