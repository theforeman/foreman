import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import {
  inputData,
  mockChartConfig,
  emptyChartConfig,
} from './DonutChart.fixtures';
import DonutChart from './';
import * as chartService from '../../../../../services/charts/DonutChartService';

// Mock the DonutChartService
jest.mock('../../../../../services/charts/DonutChartService');

// Mock EmptyState to avoid Redux/CSS import issues in Jest
jest.mock('../../EmptyState', () => ({
  __esModule: true,
  default: ({ header }) => <div data-testid="empty-state">{header}</div>,
}));

describe('DonutChart', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('with valid data', () => {
    it('renders the chart with data', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      const { container } = render(<DonutChart data={inputData} />);

      // Check that the chart container is rendered
      expect(container.querySelector('.donut-chart-pf')).toBeInTheDocument();
      // Check that SVG chart is rendered
      expect(container.querySelector('svg')).toBeInTheDocument();
    });

    it('displays the percentage title for the largest segment', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      const { container } = render(
        <DonutChart
          data={inputData}
          title={{ type: 'percent', precision: 1 }}
        />
      );

      // Ubuntu has 4 out of 10 total = 40%
      // The title is rendered as text in the SVG
      expect(container.textContent).toContain('40.0%');
    });

    it('respects precision: 0 for whole number percentages', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      const { container } = render(
        <DonutChart
          data={inputData}
          title={{ type: 'percent', precision: 0 }}
        />
      );

      // Ubuntu has 4 out of 10 total = 40% (no decimal places)
      expect(container.textContent).toContain('40%');
      // Should NOT contain decimal point when precision is 0
      expect(container.textContent).not.toContain('40.0%');
    });

    it('displays the subtitle with the largest segment name', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      const { container } = render(
        <DonutChart
          data={inputData}
          title={{ type: 'percent', precision: 1 }}
        />
      );

      expect(container.textContent).toContain('Ubuntu 14.04');
    });

    it('passes data to the service for configuration', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      render(<DonutChart data={inputData} config="medium" />);

      expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(
        expect.objectContaining({
          data: inputData,
          config: 'medium',
        })
      );
    });

    it('supports custom title with primary and secondary text', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      const { container } = render(
        <DonutChart
          data={inputData}
          title={{ primary: '50', secondary: 'Hosts' }}
        />
      );

      expect(container.textContent).toContain('50');
      expect(container.textContent).toContain('Hosts');
    });

    it('passes onclick handler to the service', () => {
      const mockOnClick = jest.fn();
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      render(<DonutChart data={inputData} onclick={mockOnClick} />);

      expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(
        expect.objectContaining({
          onclick: mockOnClick,
        })
      );
    });

    it('passes searchUrl and searchFilters to the service', () => {
      const searchUrl = '/hosts?search=~VAL~';
      const searchFilters = { test: 'filter' };
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      render(
        <DonutChart
          data={inputData}
          searchUrl={searchUrl}
          searchFilters={searchFilters}
        />
      );

      expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(
        expect.objectContaining({
          searchUrl,
          searchFilters,
        })
      );
    });

    it('renders chart segments for each data item', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      const { container } = render(<DonutChart data={inputData} />);

      // ChartDonut renders path elements for each segment
      const paths = container.querySelectorAll('path');
      expect(paths.length).toBeGreaterThan(0);
    });
  });

  describe('with empty data', () => {
    it('renders EmptyState when no data is available', () => {
      chartService.getDonutChartConfig.mockReturnValue(emptyChartConfig);

      const { container } = render(<DonutChart data={[]} />);

      expect(screen.getByTestId('empty-state')).toBeInTheDocument();
      expect(screen.getByText('No data available')).toBeInTheDocument();
      // Should not render chart container
      expect(
        container.querySelector('.donut-chart-pf')
      ).not.toBeInTheDocument();
    });

    it('renders custom noDataMsg when provided', () => {
      chartService.getDonutChartConfig.mockReturnValue(emptyChartConfig);

      render(<DonutChart data={[]} noDataMsg="Custom empty message" />);

      expect(screen.getByTestId('empty-state')).toBeInTheDocument();
      expect(screen.getByText('Custom empty message')).toBeInTheDocument();
    });
  });

  describe('with different config sizes', () => {
    it('uses regular config by default', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      render(<DonutChart data={inputData} />);

      expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(
        expect.objectContaining({
          config: 'regular',
        })
      );
    });

    it('accepts medium config', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      render(<DonutChart data={inputData} config="medium" />);

      expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(
        expect.objectContaining({
          config: 'medium',
        })
      );
    });

    it('accepts large config', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      render(<DonutChart data={inputData} config="large" />);

      expect(chartService.getDonutChartConfig).toHaveBeenCalledWith(
        expect.objectContaining({
          config: 'large',
        })
      );
    });
  });
});
