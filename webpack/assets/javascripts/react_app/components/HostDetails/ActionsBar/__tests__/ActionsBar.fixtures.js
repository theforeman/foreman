export const mockHost = {
  hostId: 1,
  hostFriendlyId: 'test-host.example.com',
  hostName: 'test-host.example.com',
  computeId: 123,
  isBuild: false,
};

export const basePermissions = {
  destroy_hosts: true,
  create_hosts: true,
  edit_hosts: true,
  build_hosts: true,
  power_hosts: true,
};

export const noPermissions = {
  destroy_hosts: false,
  create_hosts: false,
  edit_hosts: false,
  build_hosts: false,
  power_hosts: false,
};

export const noPowerPermissions = {
  ...basePermissions,
  power_hosts: false,
};

export const baseProps = {
  ...mockHost,
  permissions: basePermissions,
};

export const noPowerProps = {
  ...mockHost,
  permissions: noPowerPermissions,
};

export const noPermissionProps = {
  ...mockHost,
  permissions: noPermissions,
};
