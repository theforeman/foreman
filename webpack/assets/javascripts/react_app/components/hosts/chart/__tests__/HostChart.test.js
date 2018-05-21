import React from 'react';
import { shallow } from 'enzyme';
import HostChart from '../HostChart';
import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import { STATUS } from '../../../../constants';

jest.unmock('../../../../../services/ChartService');

const fixtures = {
  'render empty state (before dispatching the REQUEST action)': {
    data: {
      url: 'something',
      name: 'chartName',
    },
    charts: {},
  },
  'render error mode': {
    data: {
      url: '/host/localhost/runtime',
      name: 'runtime',
    },
    charts: {
      runtime: {
        status: STATUS.ERROR,
        results: [],
        error: 'bad news',
      },
    },
  },
  'render loading mode': {
    data: {
      url: '#',
      name: 'ts',
    },
    charts: {
      ts: {
        status: STATUS.PENDING,
        results: [],
        error: null,
      },
    },
  },
  'render data resolved mode': {
    data: {
      url: 'host/domain1/resources',
      name: 'resources',
    },
    charts: {
      resources: {
        status: STATUS.RESOLVED,
        results: [{ label: 'data1', data: [[129321, 100]] }],
        error: null,
      },
    },
  },
};
testComponentSnapshotsWithFixtures(HostChart, fixtures);

describe('HostChart', () => {
  it('should call getChartData on mount', () => {
    const url = 'url';
    const name = 'name';
    const getChartData = jest.fn();
    shallow(<HostChart data={{ url, name }} getChartData={getChartData} />);
    expect(getChartData).toBeCalledWith(url, name);
  });
});
