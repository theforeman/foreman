export const requestData = [
  {
    id: 'operatingsystem',
    title: 'OS Distribution',
    url: 'statistics/operatingsystem',
    search: '/hosts?search=os_title=~VAL~'
  },
  {
    id: 'architecture',
    title: 'Architecture Distribution',
    url: 'statistics/architecture',
    search: '/hosts?search=facts.architecture=~VAL~'
  }
];

export const onFailureActions = [
  {
    type: 'STATISTICS_DATA_REQUEST',
    payload: [
      {
        id: 'operatingsystem',
        title: 'OS Distribution',
        url: 'statistics/operatingsystem',
        search: '/hosts?search=os_title=~VAL~'
      },
      {
        id: 'architecture',
        title: 'Architecture Distribution',
        url: 'statistics/architecture',
        search: '/hosts?search=facts.architecture=~VAL~'
      }
    ]
  },
  {
    type: 'STATISTICS_DATA_FAILURE',
    payload: { error: {}, id: 'operatingsystem' }
  },
  {
    type: 'STATISTICS_DATA_FAILURE',
    payload: { error: {}, id: 'architecture' }
  }
];
