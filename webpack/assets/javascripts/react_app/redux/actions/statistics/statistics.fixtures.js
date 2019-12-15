const payloads = {
  operatingsystem: {
    id: 'operatingsystem',
    search: '/hosts?search=os_title=~VAL~',
    title: 'OS Distribution',
    url: 'statistics/operatingsystem',
  },
  architecture: {
    id: 'architecture',
    title: 'Architecture Distribution',
    url: 'statistics/architecture',
    search: '/hosts?search=facts.architecture=~VAL~',
  },
};

export const failedRequestData = [
  payloads.operatingsystem,
  payloads.architecture,
];

export const successRequestData = [
  payloads.operatingsystem,
  payloads.architecture,
];
