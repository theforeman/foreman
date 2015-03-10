<%#
kind: PXELinux
name: Preseed default PXELinux
oses:
- Debian 6.0
- Debian 7.
- Debian 8.
- Ubuntu 10.04
- Ubuntu 12.04
- Ubuntu 13.04
- Ubuntu 14.04
%>

<% if @host.operatingsystem.name == 'Debian' -%>
<% keyboard_params = "auto=true domain=#{@host.domain}" -%>
<% else -%>
<% keyboard_params = 'console-setup/ask_detect=false console-setup/layout=USA console-setup/variant=USA keyboard-configuration/layoutcode=us localechooser/translation/warn-light=true localechooser/translation/warn-severe=true' -%>
<% end -%>
DEFAULT linux

LABEL linux
    KERNEL <%= @kernel %>
    APPEND initrd=<%= @initrd %> interface=auto url=<%= foreman_url('provision')%> ramdisk_size=10800 root=/dev/rd/0 rw auto hostname=<%= @host.name %> <%= keyboard_params %> locale=<%= @host.params['lang'] || 'en_US' %>
    IPAPPEND 2
