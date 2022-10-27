export const user = {
  impersonated_by: true,
  id: 4,
  login: 'admin',
  firstname: 'Admin',
  lastname: 'User',
  name: 'Admin User',
};

export const ColumnSelectorProps = {
  data: {
    url: `api/users/${user.id}/table_preferences`,
    controller: 'hosts',
    categories: [{
      name: 'General',
      key: 'general',
      defaultExpanded: true,
      checkProps: { checked: true },
      children: [
        {
          name: 'Name',
          key: 'name',
          checkProps: { locked: true, checked: true },
        },
        {
          name: 'Operating system',
          key: 'os_title',
          checkProps: { checked: true },
        },
        {
          name: 'Model',
          key: 'model',
          checkProps: { checked: true },
        },
        {
          name: 'Owner',
          key: 'owner',
          checkProps: { checked: true },
        },
        {
          name: 'Host group',
          key: 'hostgroup',
          checkProps: { checked: true },
        },
        {
          name: 'Last report',
          key: 'last_report',
          checkProps: { checked: true },
        },
        {
          name: 'Comment',
          key: 'comment',
          checkProps: { checked: true },
        },
      ],
    }],
    hasPreference: true,
  },
};
