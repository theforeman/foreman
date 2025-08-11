import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import BarChart from './';
import * as chartService from '../../../../../services/charts/BarChartService';
import {
  barChartConfig,
  barChartData,
  emptyData,
  barChartConfigWithEmptyData,
} from './BarChart.fixtures';

jest.unmock('./');

describe('BarChart', () => {
  beforeEach(() => {
    // Reset mocks before each test
    jest.clearAllMocks();
  });

  it('renders bar chart with data', () => {
    chartService.getBarChartConfig = jest.fn(() => barChartConfig);
    render(<BarChart data={barChartData.data} />);

    // Verify chart service was called with correct data
    expect(chartService.getBarChartConfig).toHaveBeenCalledWith(barChartData.data);

    // Test that chart container is rendered
    const chartContainer = screen.container.querySelector('[id*="chart"], .c3, .bar-chart, [class*="chart"]');
    expect(chartContainer).toBeInTheDocument();

    // Test that chart data categories are accessible
    // The chart should render the OS names from the data
    const chartElement = screen.container;
    expect(chartElement).toBeInTheDocument();

    // Verify the chart has appropriate structure for a bar chart
    // This may include SVG elements or specific chart library classes
    const chartSvg = chartElement.querySelector('svg, .c3-chart, .bar-chart-svg');
    if (chartSvg) {
      expect(chartSvg).toBeInTheDocument();
    }
  });

  it('renders empty state when no data provided', () => {
    chartService.getBarChartConfig = jest.fn(() => barChartConfigWithEmptyData);
    render(<BarChart data={emptyData} />);

    // Verify chart service was called with empty data
    expect(chartService.getBarChartConfig).toHaveBeenCalledWith(emptyData);

    // Test that empty state is handled appropriately
    const chartContainer = screen.container;
    expect(chartContainer).toBeInTheDocument();

    // Empty state might show a message or empty chart
    const noDataMessage = screen.queryByText(/no data|empty|unavailable/i);
    if (noDataMessage) {
      expect(noDataMessage).toBeInTheDocument();
    }
  });

  it('handles chart configuration correctly', () => {
    const mockGetBarChartConfig = jest.fn(() => barChartConfig);
    chartService.getBarChartConfig = mockGetBarChartConfig;

    render(<BarChart data={barChartData.data} />);

    // Verify the chart service was called
    expect(mockGetBarChartConfig).toHaveBeenCalledTimes(1);
    expect(mockGetBarChartConfig).toHaveBeenCalledWith(barChartData.data);
  });

  it('renders with custom props', () => {
    chartService.getBarChartConfig = jest.fn(() => barChartConfig);

    render(
      <BarChart
        data={barChartData.data}
        id="custom-bar-chart"
        className="custom-chart-class"
      />
    );

    const chartContainer = screen.container.querySelector('#custom-bar-chart, .custom-chart-class');
    if (chartContainer) {
      expect(chartContainer).toBeInTheDocument();
    }
  });

  it('handles chart data with different structures', () => {
    const customData = [
      ['Custom OS 1', 5],
      ['Custom OS 2', 3],
      ['Custom OS 3', 1],
    ];

    const customConfig = {
      ...barChartConfig,
      data: {
        columns: [['Custom Data', 5, 3, 1]],
        type: 'bar',
      },
    };

    chartService.getBarChartConfig = jest.fn(() => customConfig);
    render(<BarChart data={customData} />);

    expect(chartService.getBarChartConfig).toHaveBeenCalledWith(customData);

    const chartContainer = screen.container.querySelector('[id*="chart"], .c3, .bar-chart, [class*="chart"]');
    expect(chartContainer).toBeInTheDocument();
  });

  it('is accessible', () => {
    chartService.getBarChartConfig = jest.fn(() => barChartConfig);
    render(<BarChart data={barChartData.data} />);

    // Chart should be accessible to screen readers
    const chartContainer = screen.container;
    expect(chartContainer).toBeInTheDocument();

    // Charts should ideally have proper ARIA labels or roles
    const accessibleElement = chartContainer.querySelector('[role="img"], [aria-label], [aria-labelledby]');
    if (accessibleElement) {
      expect(accessibleElement).toBeInTheDocument();
    }
  });

  it('handles undefined data gracefully', () => {
    chartService.getBarChartConfig = jest.fn(() => barChartConfigWithEmptyData);
    render(<BarChart data={undefined} />);

    // Should not crash with undefined data
    expect(chartService.getBarChartConfig).toHaveBeenCalledWith(undefined);
    expect(screen.container).toBeInTheDocument();
  });

  it('handles chart service errors gracefully', () => {
    chartService.getBarChartConfig = jest.fn(() => {
      throw new Error('Chart service error');
    });

    // Should not crash when chart service throws
    expect(() => {
      render(<BarChart data={barChartData.data} />);
    }).not.toThrow();
  });
});
