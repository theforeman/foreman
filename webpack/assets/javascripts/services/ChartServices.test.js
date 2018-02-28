import { getDonutChartConfig } from './ChartService';
import { zeroedData, mixedData } from '../react_app/components/common/charts/DonutChart/DonutChart.fixtures';

jest.unmock('./ChartService');
describe('getDonutChartConfig', () => {
  it('data should be filtered', () => {
    expect(getDonutChartConfig({
      data: zeroedData,
      onclick: jest.fn(),
      config: 'regular',
      id: 'some-id',
    })).toMatchSnapshot();
  });
  it('data should not be filtered with regular size donut ', () => {
    expect(getDonutChartConfig({
      data: mixedData,
      onclick: jest.fn(),
      config: 'regular',
      id: 'some-id',
    })).toMatchSnapshot();
  });
  it('data should not be filtered with large size donut', () => {
    expect(getDonutChartConfig({
      data: mixedData,
      onclick: jest.fn(),
      config: 'large',
      id: 'some-id',
    })).toMatchSnapshot();
  });
});
