import {
  selectHostCount,
  selectFactChart,
  selectDisplayModal,
  selectFactChartData,
} from '../FactChartSelectors';
import { chartDataValues } from '../FactChart.fixtures';

describe('Fact Chart Selector', () => {
  const factChartState = {
    factChart: { modalToDisplay: { 1: true } },
    factChartAPI: { chartData: chartDataValues },
  };

  it('should count hosts', () => {
    const selected = selectHostCount(factChartState);
    expect(selected).toEqual(13);
  });

  it('should return factChart object', () => {
    const chart = selectFactChart(factChartState);

    expect(chart).toMatchSnapshot();
  });

  it('should return true for rendering modal', () => {
    const chart = selectDisplayModal(factChartState, 1);

    expect(chart).toMatchSnapshot();
  });

  it('should return factChart data', () => {
    const data = selectFactChartData(factChartState);

    expect(data).toMatchSnapshot();
  });
});
