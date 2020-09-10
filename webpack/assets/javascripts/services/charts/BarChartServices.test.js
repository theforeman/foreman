import { getBarChartConfig } from './BarChartService';
import { barChartData } from '../../react_app/components/common/charts/BarChart/BarChart.fixtures';

jest.mock('./ChartService.consts');

describe('getBarChartConfig', () => {
  it('should return regular bar chart config', () => {
    expect(
      getBarChartConfig({
        data: barChartData.data,
        config: 'regular',
        id: 'some-id',
      })
    ).toMatchSnapshot();
  });
  it('shoud return small bar chart config', () => {
    expect(
      getBarChartConfig({
        data: barChartData.data,
        config: 'small',
        id: 'some-id',
      })
    ).toMatchSnapshot();
  });
});
