import * as ace from 'ace-builds/src-noconflict/ace';

ace.config.set('basePath', '/assets/ui/');
ace.config.set('modePath', '');
ace.config.set('themePath', '');

jest.mock('jed');
jest.mock('./assets/javascripts/react_app/Root/Context/ForemanContext', () => ({
  getForemanContext: () => ({
    context: { metadata: { version: 'mocked_version' } },
  }),
  useForemanContext: () => ({ metadata: { version: 'mocked_version' } }),
  useForemanVersion: () => 'mocked_version',
  useForemanSettings: () => ({ perPage: 5 }),
  useForemanDocUrl: () => '/url',
  useForemanLocation: () => ({ title: 'location' }),
  useForemanOrganization: () => ({ title: 'organization' }),
  useForemanUser: () => ({ login: 'user' }),
  getHostsPageUrl: displayNewHostsPage =>
    displayNewHostsPage ? '/new/hosts' : '/hosts',
  useForemanSetContext: () => jest.fn(),
  useForemanHostsPageUrl: () => '/hosts',
  useForemanPermissions: () =>
    new Set(['test_permission_one', 'test_permission_two']),
}));
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
