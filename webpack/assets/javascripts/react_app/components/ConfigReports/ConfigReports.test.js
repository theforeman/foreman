import React from 'react';
import { render, screen, within } from '@testing-library/react';
import '@testing-library/jest-dom';
import ConfigReports from './ConfigReports';

const mockData = {
  metricsChartData: [['runtime', 5]],
  statusChartData: [['applied', 2]],
  metricsData: { tableData: [['config_retrieval', 10]], total: 10 },
};

describe('ConfigReports', () => {
  const renderReports = () => render(<ConfigReports data={mockData} />);

  it('renders the chart titles and metrics table content', () => {
    renderReports();

    expect(screen.getByText('Report Metrics')).toBeInTheDocument();
    expect(screen.getByText('Report Status')).toBeInTheDocument();
    expect(screen.getByText('config_retrieval')).toBeInTheDocument();
    expect(screen.getByText('Total')).toBeInTheDocument();
  });

  it('scopes the metric row value and the footer total to their own rows', () => {
    renderReports();

    // the config_retrieval row value and the footer total are both 10, scoped
    // to their own row/footer so it stays explicit (and robust to a third
    // occurrence) about which 10 is which
    const bodyRow = screen.getByText('config_retrieval').closest('tr');
    expect(within(bodyRow).getByText('10')).toBeInTheDocument();
    const footerRow = screen.getByText('Total').closest('tr');
    expect(within(footerRow).getByText('10')).toBeInTheDocument();
  });

  it('renders both the metrics and status charts', () => {
    renderReports();

    // both charts render (Victory gives each chart's container svg role="img")
    expect(screen.getAllByRole('img')).toHaveLength(2);
  });

  it('applies the expected layout and table classes', () => {
    // NOTE: the chart components (donut/bar) expose no role or accessible label
    // to query by, so the checks below deliberately rely on structural CSS
    // classes. They exist to preserve the layout guarantees the removed snapshot
    // provided. A PF5 or ChartBox class rename would require updating these
    // selectors even though the feature still works.
    const { container } = renderReports();

    // the status chart sits in the wider grid item
    expect(
      container.querySelector('.bar-chart-medium-width')
    ).toBeInTheDocument();
    // the metrics table carries the report-chart class
    expect(screen.getByRole('table')).toHaveClass('report-chart');
    // the metric name cell uses the break-me class
    expect(screen.getByText('config_retrieval')).toHaveClass('break-me');
  });

  it('wires each chart to its own data series', () => {
    // NOTE: charts expose no role/label, so each card is located by its title
    // via the structural report-chart class; this disambiguates the two
    // otherwise-identical chart cards.
    renderReports();

    const metricsChart = screen
      .getByText('Report Metrics')
      .closest('.chart-box.report-chart');
    const statusChart = screen
      .getByText('Report Status')
      .closest('.chart-box.report-chart');
    expect(metricsChart).toBeInTheDocument();
    expect(statusChart).toBeInTheDocument();
    // each card renders its chart svg
    expect(metricsChart.querySelector('svg')).toBeInTheDocument();
    expect(statusChart.querySelector('svg')).toBeInTheDocument();

    // each chart is wired to its own data series (the label renders in the svg),
    // guarding against the metrics/status data being swapped
    expect(metricsChart).toHaveTextContent('runtime');
    expect(metricsChart).not.toHaveTextContent('applied');
    expect(statusChart).toHaveTextContent('applied');
    expect(statusChart).not.toHaveTextContent('runtime');
  });
});
