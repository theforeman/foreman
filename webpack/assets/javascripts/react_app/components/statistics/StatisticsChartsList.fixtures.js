export const statisticsData = [
  {
    id: 'operatingsystem',
    title: 'OS Distribution',
    url: 'statistics/operatingsystem',
    search: '/hosts?search=os_title=~VAL~',
  },
  {
    id: 'architecture',
    title: 'Architecture Distribution',
    url: 'statistics/architecture',
    search: '/hosts?search=facts.architecture=~VAL~',
  },
];
