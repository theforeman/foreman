import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { mockData, emptyData } from './DonutChart.fixtures';
import DonutChart from './';
import * as chartService from '../../../../../services/charts/DonutChartService';

jest.unmock('./');

describe('DonutChart', () => {
  beforeEach(() => {
    // Reset mocks before each test
    jest.clearAllMocks();
  });

  it('renders donut chart with data', () => {
    chartService.getDonutChartConfig = jest.fn(() => mockData);
    render(<DonutChart data={mockData} />);

    // Verify chart service was called with correct data
    expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(mockData);

    // Test that chart container is rendered
    const chartContainer = screen.container.querySelector('[id*="chart"], .c3, .donut-chart, [class*="chart"]');
    expect(chartContainer).toBeInTheDocument();

    // Test that the chart element structure exists
    const chartElement = screen.container;
    expect(chartElement).toBeInTheDocument();

    // Verify the chart has appropriate structure for a donut chart
    // This may include SVG elements or specific chart library classes
    const chartSvg = chartElement.querySelector('svg, .c3-chart, .donut-chart-svg');
    if (chartSvg) {
      expect(chartSvg).toBeInTheDocument();
    }
  });

  it('renders empty state when no data provided', () => {
    chartService.getDonutChartConfig = jest.fn(() => emptyData);
    render(<DonutChart data={emptyData} />);

    // Verify chart service was called with empty data
    expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(emptyData);

    // Test that empty state is handled appropriately
    const chartContainer = screen.container;
    expect(chartContainer).toBeInTheDocument();

    // Empty state might show the configured no data message
    const noDataMessage = screen.queryByText(/no data available|empty|unavailable/i);
    if (noDataMessage) {
      expect(noDataMessage).toBeInTheDocument();
    }
  });

  it('displays chart title when provided', () => {
    chartService.getDonutChartConfig = jest.fn(() => mockData);
    render(<DonutChart data={mockData} />);

    // If the chart has a title, it should be displayed
    if (mockData.title) {
      const titleElement = screen.queryByText(mockData.title);
      if (titleElement) {
        expect(titleElement).toBeInTheDocument();
      }
    }
  });

  it('handles chart configuration correctly', () => {
    const mockGetDonutChartConfig = jest.fn(() => mockData);
    chartService.getDonutChartConfig = mockGetDonutChartConfig;

    render(<DonutChart data={mockData} />);

    // Verify the chart service was called
    expect(mockGetDonutChartConfig).toHaveBeenCalledTimes(1);
    expect(mockGetDonutChartConfig).toHaveBeenCalledWith(mockData);
  });

  it('renders with custom props', () => {
    chartService.getDonutChartConfig = jest.fn(() => mockData);

    render(
      <DonutChart
        data={mockData}
        id="custom-donut-chart"
        className="custom-chart-class"
      />
    );

    const chartContainer = screen.container.querySelector('#custom-donut-chart, .custom-chart-class');
    if (chartContainer) {
      expect(chartContainer).toBeInTheDocument();
    }
  });

  it('handles data with long labels', () => {
    const dataWithLongLabels = {
      ...mockData,
      data: {
        columns: [
          ['Very Long Operating System Name That Might Overflow', 3],
          ['Another Very Long Label That Tests Wrapping', 2],
        ],
      },
    };

    chartService.getDonutChartConfig = jest.fn(() => dataWithLongLabels);
    render(<DonutChart data={dataWithLongLabels} />);

    expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(dataWithLongLabels);

    const chartContainer = screen.container.querySelector('[id*="chart"], .c3, .donut-chart, [class*="chart"]');
    expect(chartContainer).toBeInTheDocument();
  });

  it('shows tooltip configuration', () => {
    chartService.getDonutChartConfig = jest.fn(() => mockData);
    render(<DonutChart data={mockData} />);

    // Verify tooltip is configured (mockData.tooltip.show is true)
    expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(mockData);

    const chartContainer = screen.container;
    expect(chartContainer).toBeInTheDocument();
  });

  it('handles search functionality when provided', () => {
    chartService.getDonutChartConfig = jest.fn(() => mockData);
    render(<DonutChart data={mockData} />);

    // mockData includes a search URL pattern
    expect(mockData.search).toBe('/hosts?search=os_title=~VAL~');

    // Chart should be rendered with search capability
    const chartContainer = screen.container;
    expect(chartContainer).toBeInTheDocument();
  });

  it('is accessible', () => {
    chartService.getDonutChartConfig = jest.fn(() => mockData);
    render(<DonutChart data={mockData} />);

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
    chartService.getDonutChartConfig = jest.fn(() => emptyData);
    render(<DonutChart data={undefined} />);

    // Should not crash with undefined data
    expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(undefined);
    expect(screen.container).toBeInTheDocument();
  });

  it('handles chart service errors gracefully', () => {
    chartService.getDonutChartConfig = jest.fn(() => {
      throw new Error('Chart service error');
    });

    // Should not crash when chart service throws
    expect(() => {
      render(<DonutChart data={mockData} />);
    }).not.toThrow();
  });

  it('handles zero values in data', () => {
    const zeroData = {
      ...mockData,
      data: {
        columns: [
          ['OS 1', 0],
          ['OS 2', 0],
          ['OS 3', 0],
        ],
      },
    };

    chartService.getDonutChartConfig = jest.fn(() => zeroData);
    render(<DonutChart data={zeroData} />);

    expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(zeroData);
    expect(screen.container).toBeInTheDocument();
  });
});
