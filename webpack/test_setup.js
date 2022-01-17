jest.mock('jed');
jest.mock('./assets/javascripts/react_app/Root/Context/ForemanContext', () => ({
  useForemanVersion: () => 'mocked_version',
  useForemanSettings: () => ({ perPage: 5 }),
  useForemanDocUrl: () => '/url',
  useForemanLocation: () => ({ title: 'location' }),
  useForemanOrganization: () => ({ title: 'organization' }),
}));
jest.mock('./assets/javascripts/react_app/common/I18n');
jest.mock('./assets/javascripts/foreman_tools', () => ({
  foremanUrl: url => url,
}));
jest.mock('./assets/javascripts/foreman_navigation');
