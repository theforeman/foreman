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
  useForemanSetContext: () => {},
  useForemanVersion: () => 'mocked_version',
  useForemanSettings: () => ({ perPage: 5 }),
  useForemanDocUrl: () => '/url',
  useForemanLocation: () => ({ title: 'location' }),
  useForemanOrganization: () => ({ title: 'organization' }),
  useForemanUser: () => ({ login: 'user' }),
  getHostsPageUrl: displayNewHostsPage =>
    displayNewHostsPage ? '/new/hosts' : '/hosts',
  useForemanHostsPageUrl: () => '/hosts',
}));
jest.mock('./assets/javascripts/react_app/common/I18n');
jest.mock('./assets/javascripts/foreman_tools', () => ({
  foremanUrl: url => url,
}));
jest.mock('./assets/javascripts/foreman_navigation');
