const mockOnClick = jest.fn();

const PFitems = [
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
  {
    title: 'Configure',
    initialActive: false,
    iconClass: 'fa fa-wrench',
    subItems: subItemsC,
    href: '/c',
  },
];

const subItemsA = [
  {
    title: 'Aa',
    isDivider: false,
    onClick: mockOnClick,
  },
  {
    title: 'Cc',
    isDivider: false,
    onClick: mockOnClick,
  },
];
const subItemsB = [
  {
    title: 'Dd',
    isDivider: false,
    onClick: mockOnClick,
  },
  {
    title: 'Ff',
    isDivider: false,
    onClick: mockOnClick,
  },
];
const subItemsC = [
  {
    title: 'Gg',
    isDivider: false,
    onClick: mockOnClick,
  },
  {
    title: 'Ii',
    isDivider: false,
    onClick: mockOnClick,
  },
];

// Server Hash Data
const monitorChildren = [
  {
    type: 'item',
    name: 'Dashboard',
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
  {
    type: 'item',
    name: 'Architectures',
    url: '/architectures',
  },
];

const userChildren = [
  {
    type: 'item',
    name: 'Environments',
    url: '/environments',
  },
  {
    type: 'item',
    name: 'Architectures',
    url: '/architectures',
  },
];
const infrastructureChildren = [
  {
    type: 'item',
    name: 'Domains',
    url: '/domains',
  },
  {
    type: 'item',
    name: 'Realms',
    url: '/realms',
  },
];

const hashItemsA = [
  {
    type: 'sub_menu',
    name: 'Monitor',
    icon: 'fa fa-tachometer',
    children: monitorChildren,
    active: false,
  },
  {
    type: 'sub_menu',
    name: 'Hosts',
    icon: 'fa fa-server',
    children: hostsChildren,
    active: false,
  },
];

const hashItemsB = [
  {
    type: 'sub_menu',
    name: 'User',
    icon: 'fa fa-wrench',
    children: userChildren,
    active: false,
  },
  {
    type: 'sub_menu',
    name: 'Infrastructure',
    icon: 'pficon pficon-network',
    children: infrastructureChildren,
    active: false,
  },
];

export const serverItems = [...hashItemsA, ...hashItemsB];

const logo =
  '/assets/header_logo-c9614c16f2ee399ae9cb7f36ec94b9a26bf8cf9eabaa7fe6099bf80d1f7940db.svg';
const user = {
  current_user: {
    user: {
      id: 4,
      login: 'admin',
      firstname: 'Admin',
      lastname: 'User',
      name: 'Admin User',
    },
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
    user: {
      firstname: 'G',
      lastname: 'L',
      name: 'G L',
    },
  },
  user_dropdown: [
    {
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
  items: PFitems,
  activeMenu: 'Monitor',
  history: {
    push: jest.fn(),
  },
  data: {
    menu: [...hashItemsA, ...hashItemsB],
    locations,
    orgs: organizations,
    root: '/',
    logo,
    notification_url: '/notification_recipients',
    taxonomies: { locations: true, organizations: true },
    user,
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
};
