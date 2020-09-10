import Immutable from 'seamless-immutable';

export const getTaskSuccessResponse = Immutable({
  id: 'eb1b6271-8a69-4d98-84fc-bea06ddcc166',
  label: 'Actions::Katello::Organization::ManifestRefresh',
  pending: false,
  username: 'admin',
  started_at: '2018-04-15 16:53:05 -0400',
  ended_at: null,
  state: 'running',
  result: 'pending',
  progress: 0.09074410163339383,
  input: {
    organization: {
      id: 1,
      name: 'Default Organization',
      label: 'Default_Organization',
    },
    services_checked: ['candlepin', 'candlepin_auth', 'pulp', 'pulp_auth'],
    remote_user: 'admin',
    remote_cp_user: 'admin',
    locale: 'en',
    current_user_id: 4,
  },
  output: {},
  humanized: {
    action: 'Refresh Manifest',
    input: [
      [
        'organization',
        {
          text: "organization 'Default Organization'",
          link: '/organizations/1/edit',
        },
      ],
    ],
    output: '',
    errors: [],
  },
  cli_example: null,
});
