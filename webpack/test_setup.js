jest.mock('jed');
jest.mock('./assets/javascripts/react_app/Root/Context/ForemanContext', () => ({
  useForemanVersion: () => 'mocked_version',
  useForemanSettings: () => ({ perPage: 5 }),
  useForemanDocUrl: () => '/url',
  usePaginationOptions: () => [5, 10, 20, 50],
}));
jest.mock('./assets/javascripts/react_app/common/I18n');
jest.mock('./assets/javascripts/foreman_tools', () => ({
  foremanUrl: url => url,
}));
jest.mock('./assets/javascripts/foreman_navigation');
