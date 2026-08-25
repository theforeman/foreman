import { DownloadUtilities } from '../components/fields/DownloadUtility';

export const generalComponentProps = {
  organizationId: 0,
  organizations: [],
  operatingSystems: [],
  smartProxies: [],
  locations: [],
  handleOrganization: () => {},
  locationId: 0,
  handleLocation: () => {},
  hostGroupId: 0,
  hostGroups: [],
  handleHostGroup: () => {},
  operatingSystemId: 0,
  operatingSystemTemplate: '',
  handleOperatingSystem: () => {},
  smartProxyId: 0,
  handleSmartProxy: () => {},
  insecure: false,
  handleInsecure: () => {},
  handleInvalidField: () => {},
  isLoading: false,
  downloadUtility: DownloadUtilities.curl,
  handleDownloadUtility: () => {},
};
export const advancedComponentProps = {
  configParams: {},
  setupRemoteExecution: '',
  setupInsights: '',
  handleInsights: () => {},
  handleRemoteExecution: () => {},
  jwtExpiration: '',
  handleJwtExpiration: () => {},
  handleInvalidField: () => {},
  packages: '',
  handlePackages: () => {},
  repoData: [],
  handleRepoData: () => {},
  updatePackages: false,
  handleUpdatePackages: () => {},
  isLoading: false,
};

export const commandComponentProps = {
  apiStatus: 'RESOLVED',
  command: 'command',
};

export const configParamsProps = {
  configParams: {},
  setupRemoteExecution: '',
  setupInsights: '',
  handleRemoteExecution: () => {},
  handleInsights: () => {},
  isLoading: false,
};

export const hostGroupProps = {
  hostGroupId: 0,
  handleHostGroup: () => {},
  isLoading: false,
  hostGroups: [{ id: 0, title: 'test_hg' }],
};

export const osProps = {
  operatingSystemId: 0,
  operatingSystems: [],
  operatingSystemTemplate: {},
  handleOperatingSystem: () => {},
  handleInvalidField: () => {},
  hostGroupId: 0,
  hostGroups: [],
  isLoading: false,
};

export const repositoryProps = {
  repoData: [],
  handleRepoData: () => {},
  isLoading: false,
};

export const taxonomiesProps = {
  organizationId: 0,
  organizations: [],
  handleOrganization: () => {},
  locationId: 0,
  locations: [],
  handleLocation: () => {},
  isLoading: false,
};

export const tokenLifeTimeProps = {
  value: 4,
  onChange: () => {},
  handleInvalidField: () => {},
  isLoading: false,
};

export const formData = {
  organizations: [
    {
      id: 1,
      name: 'Default Organization',
    },
    {
      id: 3,
      name: 'ACME',
    },
  ],
  locations: [
    {
      id: 2,
      name: 'Default Location',
    },
    {
      id: 4,
      name: 'munich',
    },
  ],
};
