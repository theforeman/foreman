const mockOnClick = jest.fn();

const subItemsA = [
  {
    title: 'Aa',
    isDivider: false,
    onClick: mockOnClick,
    href: '/a',
    id: 'menu_item_aa',
  },
  {
    title: 'Cc',
    isDivider: false,
    onClick: mockOnClick,
    href: '/c',
    id: 'menu_item_cc',
  },
];
const subItemsB = [
  {
    title: 'Dd',
    isDivider: false,
    onClick: mockOnClick,
    href: '/d',
    id: 'menu_item_dd',
  },
];

const PFitems = [
  {
    title: 'Monitor',
    initialActive: true,
    iconClass: 'fa fa-tachometer',
    subItems: subItemsA,
  },
  {
    title: 'Hosts',
    initialActive: false,
    iconClass: 'fa fa-server',
    subItems: subItemsB,
  },
];
// Server Hash Data
const monitorChildren = [
  {
    type: 'item',
    name: 'Dashboard',
    title: 'Dashboard',
    exact: true,
    url: '/',
  },
  {
    type: 'item',
    name: 'Facts',
    title: 'Facts',
    url: '/fact_values',
  },
];

const hostsChildren = [
  {
    type: 'item',
    name: 'All Hosts',
    title: 'All Hosts',
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

export const userDropdownProps = {
  user: serverUser,
  notification_url: '/',
  isOpen: true,
};

export const fullLayoutStore = {
  layout: {
    items: [
      {
        type: 'sub_menu',
        name: 'Monitor',
        icon: 'fa fa-tachometer',
        children: [
          {
            type: 'item',
            exact: true,
            html_options: {},
            name: 'Dashboard',
            url: '/',
            title: 'Dashboard',
          },
          {
            type: 'item',
            exact: false,
            html_options: {},
            name: 'Facts',
            url: '/fact_values',
            title: 'Facts',
          },
          {
            type: 'item',
            exact: false,
            html_options: {},
            name: 'Audits',
            url: '/audits',
            title: 'Audits',
          },
          {
            type: 'divider',
            name: 'Reports',
            title: 'Reports',
          },
          {
            type: 'item',
            exact: false,
            html_options: {},
            name: 'Config Management',
            url: '/config_reports?search=eventful+%3D+true',
            title: 'Config Management',
          },
          {
            type: 'item',
            exact: false,
            html_options: {},
            name: 'Report Templates',
            url: '/templates/report_templates',
            title: 'Report Templates',
          },
        ],
        className: '',
      },
      {
        type: 'sub_menu',
        name: 'Hosts',
        icon: 'fa fa-server',
        children: [
          {
            type: 'item',
            exact: false,
            html_options: {},
            name: 'All Hosts',
            url: '/hosts',
            title: 'All Hosts',
          },
          {
            type: 'item',
            exact: false,
            html_options: {},
            name: 'Create Host',
            url: '/hosts/new',
            title: 'Create Host',
          },
          {
            type: 'divider',
            name: 'Provisioning Setup',
            title: 'Provisioning Setup',
          },
          {
            type: 'item',
            exact: false,
            html_options: {},
            name: 'Architectures',
            url: '/architectures',
            title: 'Architectures',
          },
        ],
        className: '',
      },
    ],
    isLoading: false,
    isCollapsed: false,
    currentOrganization: 'Default Organization',
    currentLocation: 'Default Location',
  },
};

export const layoutData = {
  menu: [
    {
      type: 'sub_menu',
      name: 'Monitor',
      icon: 'fa fa-tachometer',
      children: [
        {
          type: 'item',
          exact: true,
          html_options: {},
          name: 'Dashboard',
          url: '/',
        },
        {
          type: 'item',
          exact: false,
          html_options: {},
          name: 'Facts',
          url: '/fact_values',
        },
        {
          type: 'item',
          exact: false,
          html_options: {},
          name: 'Audits',
          url: '/audits',
        },
        {
          type: 'divider',
          name: 'Reports',
        },
        {
          type: 'item',
          exact: false,
          html_options: {},
          name: 'Config Management',
          url: '/config_reports?search=eventful+%3D+true',
        },
        {
          type: 'item',
          exact: false,
          html_options: {},
          name: 'Report Templates',
          url: '/templates/report_templates',
        },
      ],
    },
    {
      type: 'sub_menu',
      name: 'Hosts',
      icon: 'fa fa-server',
      children: [
        {
          type: 'item',
          exact: false,
          html_options: {},
          name: 'All Hosts',
          url: '/hosts',
        },
        {
          type: 'item',
          exact: false,
          html_options: {},
          name: 'Create Host',
          url: '/hosts/new',
        },
        {
          type: 'divider',
          name: 'Provisioning Setup',
        },
        {
          type: 'item',
          exact: false,
          html_options: {},
          name: 'Architectures',
          url: '/architectures',
        },
      ],
    },
    {
      type: 'sub_menu',
      name: 'Configure',
      icon: 'fa fa-wrench',
      children: [
        {
          type: 'item',
          exact: false,
          html_options: {},
          name: 'Host Groups',
          url: '/hostgroups',
        },
        {
          type: 'item',
          exact: false,
          html_options: {},
          name: 'Global Parameters',
          url: '/common_parameters',
        },
      ],
    },
  ],
  root: '/',
  logo,
  notification_url: '/notification_recipients',
  user,
  stop_impersonation_url: '/users/stop_impersonation',
  instance_title: 'Production',
  brand: 'foreman',
  locations: {
    current_location: 'london',
    available_locations: [
      {
        id: 2,
        title: 'london',
        href: '/locations/2-london/select',
      },
      {
        id: 3,
        title: 'norway',
        href: '/locations/3-norway/select',
      },
    ],
  },
  orgs: {
    current_org: 'org1',
    available_organizations: [
      {
        id: 1,
        title: 'org1',
        href: '/organizations/1-org1/select',
      },
      {
        id: 2,
        title: 'org2',
        href: '/organizations/2-org2/select',
      },
    ],
  },
};

export const layoutMock = {
  items: PFitems,
  data: layoutData,
  setNavigationActiveItem: jest.fn(),
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
