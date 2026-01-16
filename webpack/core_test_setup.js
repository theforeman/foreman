import * as ace from 'ace-builds/src-noconflict/ace';

ace.config.set('basePath', '/assets/ui/');
ace.config.set('modePath', '');
ace.config.set('themePath', '');

jest.mock('jed');
jest.mock('./assets/javascripts/react_app/Root/Context/ForemanContext', () => {
  const originalModule = jest.requireActual(
    './assets/javascripts/react_app/Root/Context/ForemanContext'
  );
  const permissionsSet = new Set([
    'test_permission_one',
    'test_permission_two',
  ]);
  const metadata = {
    UISettings: {
      perPage: 20,
      destroyVmOnHostDelete: false,
      labFeatures: false,
      safeMode: true,
      displayFqdnForHosts: true,
      displayNewHostsPage: true,
      displayNewHostDetailsPage: true,
    },
    docUrl: 'TEST_DOC_URL',
    location: {
      id: 2,
      title: 'Default Location',
    },
    organization: {
      id: 1,
      title: 'Default Organization',
    },
    user: {
      id: 4,
      login: 'admin',
      firstname: 'Admin',
      lastname: 'User',
      admin: true,
      ui_compact_mode: false,
    },
    user_settings: {
      lab_features: false,
    },
    permissions: permissionsSet,
    version: 'mocked_version',
  };
  return {
    ...originalModule,
    getForemanContext: () => ({
      context: {
        metadata,
      },
    }),
    useForemanContext: () => ({ metadata }),
    useForemanVersion: () => metadata.version,
    useForemanSettings: () => metadata.UISettings,
    useForemanDocUrl: () => metadata.docUrl,
    useForemanLocation: () => metadata.location,
    useForemanOrganization: () => metadata.organization,
    useForemanUser: () => metadata.user,
    getHostsPageUrl: displayNewHostsPage =>
      displayNewHostsPage ? '/new/hosts' : '/hosts',
    useForemanSetContext: () => jest.fn(),
    useForemanHostsPageUrl: () => '/hosts',
    useForemanPermissions: () => metadata.permissions,
  };
});
jest.mock('./assets/javascripts/react_app/common/I18n');
jest.mock('./assets/javascripts/foreman_tools', () => ({
  foremanUrl: url => url,
}));
jest.mock('./assets/javascripts/foreman_navigation');

jest.mock('./assets/javascripts/react_app/common/helpers', () => {
  const helpers = jest.requireActual(
    './assets/javascripts/react_app/common/helpers'
  );
  return {
    ...helpers,
    visit: jest.fn(),
    reloadPage: jest.fn(),
  };
});
jest.mock('axios');
jest.mock('./assets/javascripts/react_app/redux/API/API');
