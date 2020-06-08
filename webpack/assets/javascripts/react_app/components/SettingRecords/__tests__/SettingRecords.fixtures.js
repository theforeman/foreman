export const settings = [
  {
    description: 'The default administrator email address',
    category: 'Setting::General',
    settingsType: 'string',
    default: 'root@example.com',
    createdAt: '2019-11-06 09:42:45 +0100',
    updatedAt: '2020-04-29 15:48:23 +0200',
    readonly: false,
    id: 36,
    name: 'administrator',
    fullName: 'Administrator email address',
    selectValues: null,
    value: 'root@example.com',
    configFile: 'settings.yaml',
  },
  {
    description:
      'All hosts will show a configuration status even when a Puppet smart proxy is not assigned',
    category: 'Setting::Puppet',
    settingsType: 'boolean',
    default: false,
    createdAt: '2019-11-06 09:42:45 +0100',
    updatedAt: '2019-11-06 09:42:45 +0100',
    readonly: false,
    id: 132,
    name: 'always_show_configuration_status',
    fullName: 'Always show configuration status',
    selectValues: null,
    value: false,
    configFile: 'settings.yaml',
  },
  {
    description:
      'Foreman will append domain names when new hosts are provisioned',
    category: 'Setting::General',
    settingsType: 'boolean',
    default: false,
    createdAt: '2018-01-22 14:03:38 +0100',
    updatedAt: '2018-01-22 14:03:38 +0100',
    readonly: false,
    id: 177,
    name: 'append_domain_name_for_hosts',
    fullName: 'Append domain names to the host',
    selectValues: null,
    value: true,
    configFile: 'settings.yaml',
  },
  {
    description:
      'Cost value of bcrypt password hash function for internal auth-sources (4-30). Higher value is safer but verification is slower particularly for stateless API calls and UI logins. Password change needed to take effect.',
    category: 'Setting::Auth',
    settingsType: 'integer',
    default: 4,
    createdAt: '2019-04-30 11:24:17 +0200',
    updatedAt: '2019-10-09 10:02:35 +0200',
    readonly: false,
    id: 232,
    name: 'bcrypt_cost',
    fullName: 'BCrypt password cost',
    selectValues: null,
    value: 9,
    configFile: 'settings.yaml',
  },
  {
    category: 'Setting::Provisioning',
    configFile: 'settings.yaml',
    createdAt: '2018-11-06 09:42:45 +0100',
    default: 'PXELinux global default',
    description:
      'Global default PXELinux template. This template gets deployed to all configured TFTP servers. It will not be affected by upgrades.',
    fullName: 'Global default PXELinux template',
    id: 105,
    name: 'global_PXELinux',
    readonly: false,
    selectValues: {
      'CoreOS PXELinux': 'CoreOS PXELinux',
      'FreeBSD (mfsBSD) PXELinux': 'FreeBSD (mfsBSD) PXELinux',
      'Kickstart default PXELinux': 'Kickstart default PXELinux',
      'Kickstart oVirt-RHVH PXELinux': 'Kickstart oVirt-RHVH PXELinux',
      'Preseed default PXELinux': 'Preseed default PXELinux',
      'PXELinux chain iPXE': 'PXELinux chain iPXE',
      'PXELinux chain iPXE UNDI': 'PXELinux chain iPXE UNDI',
      'PXELinux default local boot': 'PXELinux default local boot',
      'PXELinux default memdisk': 'PXELinux default memdisk',
      'PXELinux global default': 'PXELinux global default',
      'RancherOS PXELinux': 'RancherOS PXELinux',
      '[templates] A fake pxelinux': '[templates] A fake pxelinux',
      'TEST default': 'TEST default',
      'WAIK default PXELinux': 'WAIK default PXELinux',
      'Windows default PXELinux': 'Windows default PXELinux',
      'XenServer default PXELinux': 'XenServer default PXELinux',
    },
  },
  {
    category: 'Setting::Provisioning',
    configFile: 'settings.yaml',
    createdAt: '2019-11-06 09:42:45 +0100',
    updatedAt: '2019-11-06 09:42:45 +0100',
    default: '4-Users',
    description:
      'Default owner on provisioned hosts, if empty Foreman will use current user',
    fullName: 'Host owner',
    id: 85,
    name: 'host_owner',
    readonly: false,
    value: '2-Usergroups',
    selectValues: [
      {
        label: 'Select an owner',
        value: null,
      },
      {
        group_label: 'Users',
        children: [
          { label: 'canned_admin', value: '13-Users' },
          { label: 'user', value: '19-Users' },
          { label: 'viewer', value: '27-Users' },
          { label: 'admin', value: '4-Users' },
        ],
      },
      {
        group_label: 'Usergroups',
        children: [
          { label: 'basic broup', value: '1-Usergroups' },
          { label: 'view hosts group', value: '2-Usergroups' },
        ],
      },
    ],
  },
  {
    category: 'Setting::General',
    configFile: 'settings.yaml',
    createdAt: '2019-11-06 09:42:45 +0100',
    default: [],
    description:
      'Set hostnames to which requests are not to be proxied. Requests to the local host are excluded by default.',
    fullName: 'HTTP(S) proxy except hosts',
    id: 47,
    name: 'http_proxy_except_list',
    readonly: false,
    selectValues: null,
    settingsType: 'array',
    updatedAt: '2020-03-20 13:44:40 +0100',
    value: ['localhost', '127.0.0.1'],
  },
  {
    description: 'Email reply address for emails that Foreman is sending',
    category: 'Setting::Email',
    settingsType: 'string',
    default: 'root@example.com',
    createdAt: '2019-11-06 09:42:45 +0100',
    updatedAt: '2020-04-29 15:48:23 +0200',
    readonly: false,
    id: 36,
    name: 'email_reply_address',
    fullName: 'Email reply address',
    selectValues: null,
    value: 'root@example.com',
    configFile: 'settings.yaml',
  },
];

export const groupedSettings = settings.reduce((memo, setting) => {
  if (memo[setting.category]) {
    memo[setting.category] = [...memo[setting.category], setting];
  } else {
    memo[setting.category] = [setting];
  }
  return memo;
}, {});

export const withArraySelection = settings.find(
  item => item.name === 'host_owner'
);
export const withHashSelection = settings.find(
  item => item.name === 'global_PXELinux'
);
export const boolSetting = settings.find(
  item => item.name === 'append_domain_name_for_hosts'
);
export const arraySetting = settings.find(
  item => item.name === 'http_proxy_except_list'
);
export const stringSetting = settings.find(
  item => item.name === 'email_reply_address'
);
