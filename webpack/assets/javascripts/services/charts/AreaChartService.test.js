import { getAreaChartConfig } from './AreaChartService';
import { areaChartData } from '../../react_app/components/common/charts/AreaChart/AreaChart.fixtures';

jest.mock('./ChartService.consts');

describe('getAreaChartConfig', () => {
  it('should return area timeseries chart config', () => {
    expect(
      getAreaChartConfig({
        id: 'some-id',
        ...areaChartData,
      })
    ).toMatchSnapshot();
  });
});
