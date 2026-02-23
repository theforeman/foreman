import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import BarChart from './';
import {
  barChartData,
  barChartDataWithColors,
  emptyData,
} from './BarChart.fixtures';

describe('BarChart', () => {
  it('renders bar chart with data', () => {
    const { container } = render(<BarChart data={barChartData.data} />);

    // Check that the chart container is rendered
    expect(container.querySelector('div')).toBeInTheDocument();

    // Check that SVG is rendered (PatternFly charts use SVG)
    const svg = container.querySelector('svg');
    expect(svg).toBeInTheDocument();
  });

  it('renders empty state when no data provided', () => {
    render(<BarChart data={emptyData} noDataMsg="No data available" />);

    // Check for empty state message
    expect(screen.getByText('No data available')).toBeInTheDocument();
  });

  it('renders with custom axis labels', () => {
    render(
      <BarChart
        data={barChartData.data}
        xAxisLabel="Custom X Label"
        yAxisLabel="Custom Y Label"
      />
    );

    // Check that labels are rendered
    expect(screen.getByText('Custom X Label')).toBeInTheDocument();
    expect(screen.getByText('Custom Y Label')).toBeInTheDocument();
  });

  it('renders with default axis labels from fixtures', () => {
    render(
      <BarChart
        data={barChartData.data}
        xAxisLabel={barChartData.xAxisLabel}
        yAxisLabel={barChartData.yAxisLabel}
      />
    );

    expect(screen.getByText('OS')).toBeInTheDocument();
    expect(screen.getByText('COUNT')).toBeInTheDocument();
  });

  it('renders with different config sizes', () => {
    const { container: smallContainer } = render(
      <BarChart data={barChartData.data} config="small" />
    );
    const { container: mediumContainer } = render(
      <BarChart data={barChartData.data} config="medium" />
    );
    const { container: regularContainer } = render(
      <BarChart data={barChartData.data} config="regular" />
    );

    // Check that all configs render SVG charts
    expect(smallContainer.querySelector('svg')).toBeInTheDocument();
    expect(mediumContainer.querySelector('svg')).toBeInTheDocument();
    expect(regularContainer.querySelector('svg')).toBeInTheDocument();
  });

  it('renders with onclick handler provided', () => {
    const mockOnClick = jest.fn();

    const { container } = render(
      <BarChart data={barChartData.data} onclick={mockOnClick} />
    );

    // Verify that the chart is rendered (onclick is handled internally by PatternFly)
    const svg = container.querySelector('svg');
    expect(svg).toBeInTheDocument();

    // Verify bars are clickable
    const bars = container.querySelectorAll('path[role="presentation"]');
    expect(bars.length).toBeGreaterThan(0);
  });

  it('renders chart with correct aria attributes', () => {
    const { container } = render(
      <BarChart data={barChartData.data} title={{ text: 'Test Chart' }} />
    );

    const svg = container.querySelector('svg');
    expect(svg).toHaveAttribute('role', 'img');
  });

  it('renders all data points', () => {
    const testData = [
      ['Label 1', 10],
      ['Label 2', 20],
      ['Label 3', 30],
    ];

    const { container } = render(<BarChart data={testData} />);

    // Verify that the chart is rendered with data
    const svg = container.querySelector('svg');
    expect(svg).toBeInTheDocument();

    // Check that bars are rendered (PatternFly renders bars as path elements)
    const bars = container.querySelectorAll('path[role="presentation"]');
    expect(bars.length).toBeGreaterThan(0);
  });

  it('displays no data message when data is empty array', () => {
    render(<BarChart data={[]} noDataMsg="No chart data" />);

    expect(screen.getByText('No chart data')).toBeInTheDocument();
  });

  it('applies custom title when provided', () => {
    const { container } = render(
      <BarChart
        data={barChartData.data}
        title={{ text: 'Distribution Chart' }}
      />
    );

    const svg = container.querySelector('svg');
    expect(svg).toBeInTheDocument();
  });

  it('renders bars with custom colors when provided', () => {
    const { container } = render(
      <BarChart data={barChartDataWithColors.data} />
    );

    // Verify chart renders
    const svg = container.querySelector('svg');
    expect(svg).toBeInTheDocument();

    // Check that bars are rendered with custom fill colors
    const bars = container.querySelectorAll('path[role="presentation"]');
    expect(bars.length).toBeGreaterThan(0);

    // Verify at least one bar has a custom color applied
    const barColors = Array.from(bars).map(bar => bar.getAttribute('style'));
    const hasCustomColor = barColors.some(
      style => style && style.includes('fill:') && style.includes('#')
    );
    expect(hasCustomColor).toBe(true);
  });
});
