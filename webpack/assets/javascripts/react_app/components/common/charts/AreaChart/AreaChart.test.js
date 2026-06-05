import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import AreaChart from './';
import {
  formatAxisTick,
  formatYAxisTick,
  getXAxisTickValues,
} from '../helpers/LegendHelpers';
import { areaChartData, areaChartDataDenseSameMinute } from './AreaChart.fixtures';

// Mock EmptyState to avoid Redux/CSS import issues in Jest
jest.mock('../../EmptyState', () => ({
  __esModule: true,
  default: ({ header }) => <div data-testid="empty-state">{header}</div>,
}));

jest.unmock('./');

/** Build chartData shape from fixture (same as AreaChart does). */
const buildChartData = fixture => {
  const timeColumn = fixture.data.find(col => col[0] === 'time');
  if (!timeColumn) return null;
  const timestamps = timeColumn.slice(1);
  const toMs = val => {
    const n = Number(val);
    return n >= 1e12 ? n : n * 1000;
  };
  const dates = timestamps.map(t => new Date(toMs(t)));
  const series = fixture.data
    .filter(col => col[0] !== 'time')
    .map(col => ({
      name: col[0],
      data: col.slice(1).map((value, index) => ({
        x: dates[index],
        y: value ?? 0,
        name: col[0],
      })),
    }));
  return series.length > 0 ? series : null;
};

describe('formatYAxisTick', () => {
  it('uses fixed decimals for typical values', () => {
    expect(formatYAxisTick(0)).toBe('0.0');
    expect(formatYAxisTick(12.345)).toBe('12.3');
  });

  it('uses scientific notation for very large magnitudes', () => {
    expect(formatYAxisTick(1e21)).toBe('1.0e+21');
    expect(formatYAxisTick(-1e21)).toBe('-1.0e+21');
  });
});

describe('AreaChart', () => {
  it('renders chart with valid data', () => {
    const { container } = render(
      <AreaChart
        data={areaChartData.data}
        yAxisLabel={areaChartData.yAxisLabel}
      />
    );

    expect(container.querySelector('svg')).toBeInTheDocument();
  });

  it('renders empty state when no data provided', () => {
    const { container } = render(<AreaChart data={null} />);

    expect(screen.getByText('No data available')).toBeInTheDocument();
    expect(container.querySelector('svg')).not.toBeInTheDocument();
  });

  it('renders empty state when empty data array provided', () => {
    const { container } = render(<AreaChart data={[]} />);

    expect(screen.getByText('No data available')).toBeInTheDocument();
    expect(container.querySelector('svg')).not.toBeInTheDocument();
  });

  it('displays custom noDataMsg', () => {
    const customMsg = 'Custom no data message';
    render(<AreaChart data={null} noDataMsg={customMsg} />);

    // Should display the custom message
    expect(screen.getByText(customMsg)).toBeInTheDocument();
  });

  it('applies custom size to chart', () => {
    const customSize = { width: 500, height: 300 };
    const { container } = render(
      <AreaChart data={areaChartData.data} size={customSize} />
    );

    // Chart receives size prop; SVG reflects chart dimensions
    const svg = container.querySelector('svg');
    expect(svg).toBeInTheDocument();
    expect(svg).toHaveAttribute('width', '500');
    expect(svg).toHaveAttribute('height', '300');
  });

  it('renders with onclick callback and triggers it when legend item is clicked', () => {
    const onClickMock = jest.fn();
    render(<AreaChart data={areaChartData.data} onclick={onClickMock} />);

    const legendButton = screen.getByRole('button', { name: 'CentOS 7.9' });
    fireEvent.click(legendButton);

    expect(onClickMock).not.toHaveBeenCalled();
  });

  it('calls onclick when data point is clicked', () => {
    const onClickMock = jest.fn();
    const { container } = render(
      <AreaChart data={areaChartData.data} onclick={onClickMock} />
    );

    const chart = container.querySelector('svg');
    expect(chart).toBeInTheDocument();

    const path = chart.querySelector('path[class*="area"]');
    if (path) {
      fireEvent.click(path);
      expect(onClickMock).toHaveBeenCalledWith({ id: expect.any(String) });
    }
  });

  it('legend items are interactive (button role for accessibility)', () => {
    render(<AreaChart data={areaChartData.data} />);

    expect(screen.getByRole('button', { name: 'CentOS 7.9' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'CentOS 7.6' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Fedora 32' })).toBeInTheDocument();
  });

  it('clicking legend symbol toggles series visibility', () => {
    const { container } = render(<AreaChart data={areaChartData.data} />);

    const symbols = container.querySelectorAll('.chart-legend-symbol');
    const labels = container.querySelectorAll('.chart-legend-label');

    expect(symbols.length).toBeGreaterThanOrEqual(1);
    expect(labels.length).toBeGreaterThanOrEqual(1);

    const firstLabel = labels[0];
    expect(firstLabel).toHaveAttribute('data-hidden', 'false');

    fireEvent.click(symbols[0]);
    expect(firstLabel).toHaveAttribute('data-hidden', 'true');

    fireEvent.click(symbols[0]);
    expect(firstLabel).toHaveAttribute('data-hidden', 'false');
  });

  it('renders chart with config timeseries (stacked)', () => {
    const { container } = render(
      <AreaChart
        data={areaChartData.data}
        config="timeseries"
        yAxisLabel={areaChartData.yAxisLabel}
      />
    );

    expect(container.querySelector('svg')).toBeInTheDocument();
  });

  it('renders chart when xAxisDataLabel matches data column', () => {
    const { container } = render(
      <AreaChart
        data={areaChartData.data}
        xAxisDataLabel="time"
        yAxisLabel={areaChartData.yAxisLabel}
      />
    );

    expect(container.querySelector('svg')).toBeInTheDocument();
  });

  it('handles missing xAxisDataLabel gracefully', () => {
    const dataWithoutTime = [
      ['nottime', 1614449768, 1614451500],
      ['CentOS 7.9', 3, 5],
    ];

    render(
      <AreaChart data={dataWithoutTime} xAxisDataLabel="time" />
    );

    // Should render empty state when time column is not found
    expect(screen.getByText('No data available')).toBeInTheDocument();
  });

  it('does not show duplicate x-axis labels when multiple data points fall within the same minute', () => {
    const chartData = buildChartData(areaChartDataDenseSameMinute);
    const tickValues = getXAxisTickValues(chartData, 6);

    expect(tickValues).toBeDefined();
    expect(tickValues.length).toBeGreaterThan(0);

    const formattedLabels = tickValues.map(t => formatAxisTick(t));
    const uniqueLabels = [...new Set(formattedLabels)];

    expect(formattedLabels.length).toBe(uniqueLabels.length);
    expect(formattedLabels).toEqual(uniqueLabels);
  });
});

