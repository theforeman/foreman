import Immutable from 'seamless-immutable';
import { getDonutChartConfig } from './DonutChartService';
import {
  zeroedData,
  mixedData,
  dataWithLongLabels,
} from '../../react_app/components/common/charts/DonutChart/DonutChart.fixtures';

jest.mock('./ChartService.consts');

describe('getDonutChartConfig', () => {
  it('data should be filtered', () => {
    expect(
      getDonutChartConfig({
        data: zeroedData,
        onclick: jest.fn(),
        config: 'regular',
        id: 'some-id',
      })
    ).toMatchSnapshot();
  });
  it('data should not be filtered with regular size donut ', () => {
    expect(
      getDonutChartConfig(
        Immutable({
          data: mixedData,
          onclick: jest.fn(),
          config: 'regular',
          id: 'some-id',
        })
      )
    ).toMatchSnapshot();
  });
  it('data should not be filtered with large size donut', () => {
    expect(
      getDonutChartConfig(
        Immutable({
          data: mixedData,
          onclick: jest.fn(),
          config: 'large',
          id: 'some-id',
        })
      )
    ).toMatchSnapshot();
  });
  it('data with long labels should be trimmed', () => {
    expect(
      getDonutChartConfig(
        Immutable({
          data: dataWithLongLabels,
          onclick: jest.fn(),
          config: 'regular',
          id: 'some-id',
        })
      )
    ).toMatchSnapshot();
  });
});
