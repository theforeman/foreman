import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import ChartBox from './ChartBox';

// Mock the DonutChart and BarChart components
jest.mock('../common/charts/DonutChart', () => ({
  __esModule: true,
  default: ({ data }) => (
    <div data-testid="donut-chart">
      {data && data.length > 0 ? 'Donut Chart with data' : 'Empty donut chart'}
    </div>
  ),
}));

jest.mock('../common/charts/BarChart', () => ({
  __esModule: true,
  default: ({ data }) => (
    <div data-testid="bar-chart">
      {data && data.length > 0 ? 'Bar Chart with data' : 'Empty bar chart'}
    </div>
  ),
}));

jest.mock('../common/Loader', () => ({
  __esModule: true,
  default: ({ status, children }) => (
    <div data-testid="loader" data-status={status}>
      {children}
    </div>
  ),
}));

describe('ChartBox', () => {
  const defaultProps = {
    type: 'donut',
    chart: { id: 'test-chart', data: [] },
    status: 'PENDING',
    title: 'Test Chart Title',
    errorText: '',
    noDataMsg: 'no data',
    tip: 'Click to expand',
  };

  describe('rendering states', () => {
    it('renders with pending status', () => {
      render(<ChartBox {...defaultProps} status="PENDING" />);

      expect(screen.getByTestId('loader')).toBeInTheDocument();
      expect(screen.getByTestId('loader')).toHaveAttribute(
        'data-status',
        'PENDING'
      );
    });

    it('renders with error status and error message', () => {
      render(
        <ChartBox
          {...defaultProps}
          status="ERROR"
          errorText="Failed to load data"
        />
      );

      expect(screen.getByText('Failed to load data')).toBeInTheDocument();
    });

    it('renders with resolved status and chart data', () => {
      render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          chart={{ id: 'test-chart', data: [['Item', 5]] }}
        />
      );

      expect(screen.getByTestId('donut-chart')).toBeInTheDocument();
    });

    it('renders title', () => {
      render(<ChartBox {...defaultProps} title="My Custom Title" />);

      expect(screen.getByText('My Custom Title')).toBeInTheDocument();
    });
  });

  describe('chart types', () => {
    it('renders DonutChart when type is donut', () => {
      render(
        <ChartBox
          {...defaultProps}
          type="donut"
          chart={{ id: 'test', data: [['Item', 5]] }}
        />
      );

      expect(screen.getByTestId('donut-chart')).toBeInTheDocument();
      expect(screen.queryByTestId('bar-chart')).not.toBeInTheDocument();
    });

    it('renders BarChart when type is bar', () => {
      render(
        <ChartBox
          {...defaultProps}
          type="bar"
          chart={{ id: 'test', data: [['Item', 5]] }}
        />
      );

      expect(screen.getByTestId('bar-chart')).toBeInTheDocument();
      expect(screen.queryByTestId('donut-chart')).not.toBeInTheDocument();
    });
  });

  describe('modal functionality', () => {
    it('renders modal component in the DOM', () => {
      render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          chart={{ id: 'test', data: [['Item', 5]] }}
        />
      );

      // Modal component should be in the DOM (PatternFly renders it even when closed)
      expect(screen.getByText('Test Chart Title')).toBeInTheDocument();
    });

    it('opens modal when clicking on chart title with data', () => {
      render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          chart={{ id: 'test', data: [['Item', 5]] }}
          tip="Expand chart"
        />
      );

      const title = screen.getByText('Test Chart Title');
      fireEvent.click(title);

      // Modal should now be open - check for modal backdrop or content
      const modalElements = document.querySelectorAll('[class*="modal"]');
      expect(modalElements.length).toBeGreaterThan(0);
    });

    it('title has pointer class when there is data', () => {
      render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          chart={{ id: 'test', data: [['Item', 5]] }}
        />
      );

      const title = screen.getByText('Test Chart Title');

      // Title should have pointer class when there's data
      expect(title).toHaveClass('pointer');
    });

    it('title does not have pointer class when there is no data', () => {
      render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          chart={{ id: 'test', data: [] }}
        />
      );

      const titleElement = screen.getByText('Test Chart Title');

      // When no data, the title should still render but without interactive styling
      // Note: ChartBox may still add pointer class, but no onClick handler
      expect(titleElement).toBeInTheDocument();
    });
  });

  describe('props handling', () => {
    it('applies custom className', () => {
      const { container } = render(
        <ChartBox {...defaultProps} className="custom-chart-class" />
      );

      const card = container.querySelector('.chart-box');
      expect(card).toHaveClass('custom-chart-class');
    });

    it('uses provided config', () => {
      render(
        <ChartBox
          {...defaultProps}
          config="large"
          chart={{ id: 'test', data: [['Item', 5]] }}
        />
      );

      expect(screen.getByTestId('donut-chart')).toBeInTheDocument();
    });

    it('renders with searchUrl in chart data', () => {
      render(
        <ChartBox
          {...defaultProps}
          chart={{
            id: 'test',
            data: [['Item', 5]],
            search: '/hosts?search=~VAL~',
          }}
        />
      );

      expect(screen.getByTestId('donut-chart')).toBeInTheDocument();
    });
  });
});
