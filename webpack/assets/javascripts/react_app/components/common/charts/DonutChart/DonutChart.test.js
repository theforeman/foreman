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

// Mock the ChartDonut component from PatternFly
jest.mock('@patternfly/react-charts', () => ({
  ChartDonut: ({ title, subTitle, data }) => (
    <div data-testid="chart-donut">
      {title && <div data-testid="chart-title">{title}</div>}
      {subTitle && <div data-testid="chart-subtitle">{subTitle}</div>}
      {data && data.length > 0 && (
        <div data-testid="chart-data">
          {data.map((d, i) => (
            <div key={i} data-testid={`chart-segment-${i}`}>
              {d.x}: {d.y}
            </div>
          ))}
        </div>
      )}
    </div>
  ),
  ChartThemeColor: {
    multiOrdered: 'multiOrdered',
  },
}));

jest.mock('../../../../../services/charts/DonutChartService');

describe('DonutChart', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('with valid data', () => {
    it('renders the chart with data', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      render(<DonutChart data={inputData} />);

      expect(screen.getByTestId('chart-donut')).toBeInTheDocument();
      expect(screen.getByTestId('chart-data')).toBeInTheDocument();
    });

    it('displays the percentage title for the largest segment', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      render(
        <DonutChart
          data={inputData}
          title={{ type: 'percent', precision: 1 }}
        />
      );

      // Ubuntu has 4 out of 10 total = 40%
      expect(screen.getByTestId('chart-title')).toHaveTextContent('40.0%');
    });

    it('displays the subtitle with the largest segment name', () => {
      chartService.getDonutChartConfig.mockReturnValue(mockChartConfig);

      render(
        <DonutChart
          data={inputData}
          title={{ type: 'percent', precision: 1 }}
        />
      );

      expect(screen.getByTestId('chart-subtitle')).toHaveTextContent(
        'Ubuntu 14.04'
      );
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

      render(
        <DonutChart
          data={inputData}
          title={{ primary: '50', secondary: 'Hosts' }}
        />
      );

      expect(screen.getByTestId('chart-title')).toHaveTextContent('50');
      expect(screen.getByTestId('chart-subtitle')).toHaveTextContent('Hosts');
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
  });

  describe('with empty data', () => {
    it('renders MessageBox when no data is available', () => {
      chartService.getDonutChartConfig.mockReturnValue(emptyChartConfig);

      render(<DonutChart data={[]} />);

      expect(screen.getByText('No data available')).toBeInTheDocument();
      expect(screen.queryByTestId('chart-donut')).not.toBeInTheDocument();
    });

    it('renders custom noDataMsg when provided', () => {
      chartService.getDonutChartConfig.mockReturnValue(emptyChartConfig);

      render(<DonutChart data={[]} noDataMsg="Custom empty message" />);

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
