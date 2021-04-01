const mockOnClick = jest.fn();

const subItemsA = [
  {
    title: 'Aa',
    isDivider: false,
    onClick: mockOnClick,
    href: '/Aa',
  },
  {
    title: 'Cc',
    isDivider: false,
    onClick: mockOnClick,
    href: '/Cc',
  },
];
const subItemsB = [
  {
    title: 'Dd',
    isDivider: false,
    onClick: mockOnClick,
    href: '/Dd',
  },
];

const pfItems = [
  {
    title: 'Monitor',
    initialActive: true,
    iconClass: 'fa fa-tachometer',
    subItems: subItemsA,
    href: '/a',
  },
  {
    title: 'Hosts',
    initialActive: false,
    iconClass: 'fa fa-server',
    subItems: subItemsB,
    href: '/b',
  },
];

// Server Hash Data
const monitorChildren = [
  {
    type: 'item',
    name: 'Dashboard',
    exact: true,
    url: '/',
  },
  {
    type: 'item',
    name: 'Facts',
    url: '/fact_values',
  },
];

const hostsChildren = [
  {
    type: 'item',
    name: 'All Hosts',
    url: '/hosts/new',
  },
];

const namelessChildren = [
  {
    type: 'item',
    url: '/nameless',
  },
  {
    type: 'divider',
  },
];

const hashItemsA = [
  {
    type: 'sub_menu',
    name: 'Monitor',
    icon: 'fa fa-tachometer',
    children: monitorChildren,
  },
  {
    type: 'sub_menu',
    name: 'Hosts',
    icon: 'fa fa-server',
    children: hostsChildren,
  },
];

export const hashItemNameless = [
  {
    type: 'sub_menu',
    name: 'Empty',
    icon: 'pficon pficon-unplugged',
    children: namelessChildren,
  },
];

const logo =
  '/assets/header_logo-c9614c16f2ee399ae9cb7f36ec94b9a26bf8cf9eabaa7fe6099bf80d1f7940db.svg';
const user = {
  impersonated_by: true,
  current_user: {
    id: 4,
    login: 'admin',
    firstname: 'Admin',
    lastname: 'User',
    name: 'Admin User',
  },
  user_dropdown: [
    {
      type: 'sub_menu',
      name: 'User',
      icon: 'fa fa-user',
      children: subItemsA,
    },
  ],
};

const organizations = {
  current_org: 'org1',
  available_organizations: [
    { id: 1, title: 'org1', href: '/organizations/1-org1/select' },
    { id: 2, title: 'org2', href: '/organizations/2-org2/select' },
  ],
};

const locations = {
  current_location: 'london',
  available_locations: [
    { id: 1, title: 'yaml', href: '/locations/1-yaml/select' },
    { id: 2, title: 'london', href: '/locations/2-london/select' },
    { id: 3, title: 'norway', href: '/locations/3-norway/select' },
  ],
};

const serverUser = {
  current_user: {
    firstname: 'G',
    lastname: 'L',
    name: 'G L',
  },
  user_dropdown: [
    {
      type: 'sub_menu',
      name: 'User',
      icon: 'fa fa-user',
      children: [
        {
          type: 'item',
          url: '/',
          name: 'My Account',
        },
        { type: 'divider' },
      ],
    },
  ],
};

export const layoutMock = {
  items: pfItems,
  data: {
    menu: [...hashItemsA, ...hashItemNameless],
    locations,
    orgs: organizations,
    root: '/',
    logo,
    notification_url: '/notification_recipients',
    user,
    stop_impersonation_url: '/users/stop_impersonation',
    instance_title: 'Production',
  },
};

export const noItemsMock = {
  ...layoutMock,
  items: [],
};

export const hasTaxonomiesMock = {
  ...layoutMock,
  currentLocation: 'london',
  currentOrganization: 'org1',
};

export const userDropdownProps = {
  user: serverUser,
  notification_url: '/',
  isOpen: true,
};
