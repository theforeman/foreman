import { STATUS } from '../../../../constants';

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
  repo: '',
  repoGpgKeyUrl: '',
  handleRepo: () => {},
  handleRepoGpgKeyUrl: () => {},
  isLoading: false,
};

export const actionsComponentProps = {
  isLoading: false,
  isGenerating: false,
  handleSubmit: () => {},
  invalidFields: [],
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

export const insecureProps = {
  insecure: false,
  handleInsecure: () => {},
  isLoading: false,
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

export const packagesProps = {
  packages: '',
  handlePackages: () => {},
  configParams: {},
  isLoading: false,
};

export const repositoryProps = {
  repo: '',
  handleRepo: () => {},
  repoGpgKeyUrl: '',
  handleRepoGpgKeyUrl: () => {},
  isLoading: false,
};

export const smartProxyProps = {
  smartProxyId: 0,
  smartProxies: [],
  handleSmartProxy: () => {},
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

/* Integration fixtures */

export const spySelector = selectors => {
  jest.spyOn(selectors, 'selectAPIStatusData');
  jest.spyOn(selectors, 'selectOrganizations');
  jest.spyOn(selectors, 'selectLocations');
  jest.spyOn(selectors, 'selectHostGroups');
  jest.spyOn(selectors, 'selectOperatingSystems');
  jest.spyOn(selectors, 'selectOperatingSystemTemplate');
  jest.spyOn(selectors, 'selectSmartProxies');
  jest.spyOn(selectors, 'selectConfigParams');
  jest.spyOn(selectors, 'selectPluginData');
  jest.spyOn(selectors, 'selectAPIStatusCommand');
  jest.spyOn(selectors, 'selectCommand');

  selectors.selectAPIStatusData.mockImplementation(() => STATUS.RESOLVED);
  selectors.selectOrganizations.mockImplementation(
    () => formData.organizations
  );
  selectors.selectLocations.mockImplementation(() => formData.locations);
  selectors.selectHostGroups.mockImplementation(() => []);
  selectors.selectOperatingSystems.mockImplementation(() => []);
  selectors.selectOperatingSystemTemplate.mockImplementation(() => '');
  selectors.selectSmartProxies.mockImplementation(() => []);
  selectors.selectConfigParams.mockImplementation(() => ({}));
  selectors.selectPluginData.mockImplementation(() => {});
  selectors.selectAPIStatusCommand.mockImplementation(() => undefined);
  selectors.selectCommand.mockImplementation(() => '');
};

export const formData = {
  organizations: [
    {
      id: 1,
      name: 'Default Organization',
    },
  ],
  locations: [
    {
      id: 2,
      name: 'Default Location',
    },
  ],
};
