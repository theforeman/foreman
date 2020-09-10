import { translate as __ } from '../../../common/I18n';

export const searchLinkProp = {
  textValue: 'testUser',
  url: '/audits?search=type+%3D+user+and+auditable_id+%3D+1',
  id: 123,
};

export const actionsList = [
  {
    url: '/hosts/foo.example.com',
    title: __('Host details'),
    css_class: 'btn btn-default',
  },
];

export const TaxonomyProps = {
  orgs: [
    {
      name: 'testOrg',
      url: '/organizations/1-testOrg/edit',
    },
    {
      name: 'testOrg2',
      url: '#',
      disabled: true,
      css_class: 'disabled',
    },
  ],
  locs: [
    {
      name: 'testLoc',
      url: '/locations/1-testLoc/edit',
    },
  ],
};

export const AuditRecord = {
  action: 'update',
  action_display_name: 'updated',
  affected_locations: [
    {
      name: 'testLoc',
      url: '/locations/2-testLoc/edit',
    },
  ],
  affected_organizations: [
    {
      name: 'testOrg',
      url: '/organizations/1-testOrg/edit',
    },
  ],
  allowed_actions: [
    {
      url: '/hosts/foo.example.com',
      title: __('Host details'),
      css_class: 'btn btn-default',
    },
  ],
  associated_id: null,
  associated_name: null,
  associated_type: null,
  audit_title: 'test-template',
  audit_title_url:
    '/audits?search=type+%3D+provisioning_template+and+auditable_id+%3D+1',
  auditable_id: 1,
  auditable_name: 'test-template',
  auditable_type: 'ProvisioningTemplate',
  audited_changes: {
    template: ['<h1>Hello..</h1>', '<h1>Hello World..</h1>'],
    name: ['temp1', 'temp2'],
  },
  audited_changes_with_id_to_label: [
    {
      change: [
        {
          css_class: 'show-old',
          id_to_label: 'temp1',
        },
        {
          css_class: 'show-new',
          id_to_label: 'temp2',
        },
      ],
      name: 'Name',
    },
  ],
  audited_type_name: 'Provisioning Template',
  comment: 'This is just test audit record',
  created_at: '2018-08-13 00:34:55 -1100',
  details: ['Removed test object'],
  id: 123,
  remote_address: '127.0.0.1',
  request_uuid: '4bafc809-a0e9-43db-bee8-c7abfe44ad05',
  user_id: 4,
  user_info: {
    audit_path: '/audits?search=id+%3D+123',
    display_name: 'Admin ',
    login: 'admin',
    search_path: '/audits?search=user+%3D+admin',
  },
  user_type: null,
  username: 'Admin User',
  version: 20,
};

export const AuditsProps = {
  audits: [
    {
      action: 'update',
      action_display_name: 'updated',
      affected_locations: [
        {
          name: 'test_loc1',
          url: '/locations/2-test_loc1/edit',
        },
        {
          name: 'test_loc2',
          url: '/locations/6-test_loc2/edit',
        },
        {
          name: 'test_loc3',
          url: '/locations/9-test_loc3/edit',
        },
      ],
      affected_organizations: [
        {
          name: 'test_org1',
          url: '/organizations/1-test_org1/edit',
        },
        {
          name: 'test_org2',
          url: '/organizations/3-test_org2/edit',
        },
        {
          name: 'test_org3',
          url: '/organizations/5-test_org3/edit',
        },
      ],
      allowed_actions: [
        {
          title: 'Host details',
          css_class: 'btn btn-default',
          url: '/hosts/host-foo.example.com',
        },
      ],
      associated_id: null,
      associated_name: null,
      associated_type: null,
      audit_title: 'host-foo.example.com',
      audit_title_url: '/audits?search=type+%3D+host+and+auditable_id+%3D+9',
      auditable_id: 9,
      auditable_name: 'host-foo.example.com',
      auditable_type: 'Host::Base',
      audited_changes: {
        root_pass: ['[redacted]', '[redacted]'],
        comment: ['', 'This is info about host for audit'],
      },
      audited_changes_with_id_to_label: [
        {
          change: [
            {
              css_class: 'show-old',
              id_to_label: '[redacted]',
            },
            {
              css_class: 'show-new',
              id_to_label: '[redacted]',
            },
          ],
          name: 'Root pass',
        },
        {
          change: [
            {
              css_class: 'show-old',
              id_to_label: '[empty]',
            },
            {
              css_class: 'show-new',
              id_to_label: 'This is info about host for audit',
            },
          ],
          name: 'Comment',
        },
      ],
      audited_type_name: 'Host',
      comment: null,
      created_at: '2018-08-13 00:34:55 -1100',
      id: 234,
      remote_address: '127.0.0.1',
      request_uuid: 'c134239d-8ac3-494b-9962-35133fe153ba',
      user_id: 4,
      user_info: {
        audit_path: '/audits?search=id+%3D+234',
        display_name: 'Admin ',
        login: 'admin',
        search_path: '/audits?search=user+%3D+admin',
      },
      user_type: null,
      username: 'Admin User',
      version: 2,
    },
  ],
};
