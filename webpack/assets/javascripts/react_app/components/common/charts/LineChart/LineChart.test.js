import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { data, timeseriesData } from './LineChart.fixtures';
import LineChart from './index';

jest.mock('../../../../../services/charts/ChartService.consts');

// The patternfly-react LineChart is C3-based and crashes under jsdom, so stub it
// and expose the computed chart config the component passes down (the config is
// what the original shallow snapshot verified).
jest.mock('patternfly-react', () => ({
  LineChart: props => {
    // eslint-disable-next-line global-require
    const react = require('react');
    return react.createElement('div', {
      'data-testid': 'pf-line-chart',
      'data-axis': JSON.stringify(props.axis),
      'data-columns': JSON.stringify(props.data.columns),
    });
  },
}));

describe('Line Chart', () => {
  it('renders a line chart with the data columns', () => {
    render(<LineChart data={data} id="abc" />);

    const chart = screen.getByTestId('pf-line-chart');
    const columns = JSON.parse(chart.dataset.columns);
    expect(columns).toEqual([
      ['red', 5, 7, 9],
      ['green', 2, 4, 6],
    ]);
    // regular config uses no special axis
    expect(JSON.parse(chart.dataset.axis)).toEqual({});
  });

  it('renders a timeseries line chart with a timeseries x axis', () => {
    render(
      <LineChart
        data={timeseriesData}
        xAxisDataLabel="x"
        config="timeseries"
        id="xyz"
      />
    );

    const chart = screen.getByTestId('pf-line-chart');
    const axis = JSON.parse(chart.dataset.axis);
    expect(axis.x.type).toBe('timeseries');
    // the x data column is included
    const columns = JSON.parse(chart.dataset.columns);
    expect(columns).toContainEqual([
      'x',
      1557014400000,
      1559779200000,
      1562457600000,
    ]);
  });
});
