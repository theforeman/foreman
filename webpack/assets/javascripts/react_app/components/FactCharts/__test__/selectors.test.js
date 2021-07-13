import { STATUS } from '../../../constants';
import { chartData, modalToDisplay, id, key } from '../fixtures';
import {
  selectHostCount,
  selectFactChart,
  selectDisplayModal,
  selectFactChartData,
  selectFactChartStatus,
} from '../selectors';

describe('Fact Chart Selector', () => {
  const factChartState = {
    factChart: { modalToDisplay },
    API: {
      [key]: {
        response: { values: chartData },
        status: STATUS.PENDING,
      },
    },
  };

  it('should count hosts', () => {
    const selected = selectHostCount(factChartState, key);
    expect(selected).toMatchSnapshot();
  });

  it('should return factChart object', () => {
    const chart = selectFactChart(factChartState);

    expect(chart).toMatchSnapshot();
  });

  it('should return true for rendering modal', () => {
    const chart = selectDisplayModal(factChartState, id);

    expect(chart).toMatchSnapshot();
  });

  it('should return factChart data', () => {
    const data = selectFactChartData(factChartState, key);

    expect(data).toMatchSnapshot();
  });

  it('should return factChart status', () => {
    const data = selectFactChartStatus(factChartState, key);

    expect(data).toMatchSnapshot();
  });
});
