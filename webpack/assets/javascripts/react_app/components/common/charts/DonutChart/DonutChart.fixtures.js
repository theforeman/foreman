// Input data format (what gets passed to DonutChart component)
export const inputData = [
  ['Ubuntu 14.04', 4, '#0088ce'],
  ['Fedora 21', 3, '#ec7a08'],
  ['Centos 7', 2, '#3f9c35'],
  ['Debian 8', 1, '#005c66'],
];

export const inputDataWithLongLabels = [
  [
    'Fedora 21 extra extra extra extra extra extra extra extra extra extra long label',
    3,
    '#ec7a08',
  ],
  ['Ubuntu 14.04', 4, '#0088ce'],
  ['Centos 7 extra extra long label', 2, '#3f9c35'],
  ['Debian 8', 1, '#005c66'],
];

// PF5 Victory chart config format (what getDonutChartConfig returns)
export const mockChartConfig = {
  id: 'test-chart',
  data: [
    { x: 'Ubuntu 14.04', y: 4, name: 'Ubuntu 14.04' },
    { x: 'Fedora 21', y: 3, name: 'Fedora 21' },
    { x: 'Centos 7', y: 2, name: 'Centos 7' },
    { x: 'Debian 8', y: 1, name: 'Debian 8' },
  ],
  colorScale: ['#0088ce', '#ec7a08', '#3f9c35', '#005c66'],
  width: 240,
  height: 240,
  padding: { top: 20, left: 20, right: 20, bottom: 20 },
  innerRadius: 75,
  labels: jest.fn(({ datum }) => `${datum.x}: ${datum.y}`),
  events: undefined,
  legendData: undefined,
};

export const emptyChartConfig = {
  data: [],
};

export const zeroedData = [
  ['Fedora 21', 0],
  ['Ubuntu 14.04', 0],
  ['Centos 7', 0],
  ['Debian 8', 0],
];

export const mixedData = [
  ['Fedora 21', 3],
  ['Ubuntu 14.04', 2],
  ['Centos 7', 0],
  ['Debian 8', 0],
];

export const dataWithLongLabels = [
  ['Fedora 21 extra extra extra extra extra extra long label', 3],
  ['Ubuntu 14.04 extra extra extra extra extra extra long label', 2],
  ['Centos 7 extra extra extra extra extra extra long label', 0],
  ['Debian 8 extra extra long label', 0],
];
