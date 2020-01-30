export const statisticsData = {
  operatingsystem: {
    id: 'operatingsystem',
    title: 'OS Distribution',
    url: 'statistics/operatingsystem',
    search: '/hosts?search=os_title=~VAL~',
  },
  architecture: {
    id: 'architecture',
    title: 'Architecture Distribution',
    url: 'statistics/architecture',
    search: '/hosts?search=facts.architecture=~VAL~',
  },
};

export const statisticsMeta = [
  statisticsData.operatingsystem,
  statisticsData.architecture,
];
