import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import ChartBox from './ChartBox';

// Mock DonutChart to avoid CSS import issues from MessageBox
jest.mock('../common/charts/DonutChart', () => ({
  __esModule: true,
  default: ({ data, noDataMsg }) => (
    <div data-testid="donut-chart" className="donut-chart-pf">
      {data && data.length > 0 ? (
        <svg data-testid="donut-svg">
          <text>Chart</text>
        </svg>
      ) : (
        <div data-testid="message-box">{noDataMsg || 'No data available'}</div>
      )}
    </div>
  ),
}));

// Mock BarChart since it still uses C3-based patternfly-react which doesn't work in Jest
jest.mock('../common/charts/BarChart', () => ({
  __esModule: true,
  default: ({ data }) => (
    <div data-testid="bar-chart" className="bar-chart-pf">
      {data && data.length > 0 ? 'Bar Chart with data' : 'Empty bar chart'}
    </div>
  ),
}));

// Mock MessageBox to avoid CSS import issues in Jest
jest.mock('../common/MessageBox', () => ({
  __esModule: true,
  default: ({ msg }) => <div data-testid="message-box">{msg}</div>,
}));

// Mock Loader to avoid CSS import issues
jest.mock('../common/Loader', () => ({
  __esModule: true,
  default: ({ children, status }) => (
    <div className="loader-root">
      {status === 'PENDING' ? 'Loading...' : children}
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

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('rendering states', () => {
    it('renders with pending status', () => {
      const { container } = render(
        <ChartBox {...defaultProps} status="PENDING" />
      );

      // Loader component uses .loader-root class
      expect(container.querySelector('.loader-root')).toBeInTheDocument();
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
      const { container } = render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          chart={{
            id: 'test-chart',
            data: [
              ['Item 1', 5],
              ['Item 2', 3],
            ],
          }}
        />
      );

      // Mocked DonutChart renders SVG
      expect(container.querySelector('svg')).toBeInTheDocument();
      expect(container.querySelector('.donut-chart-pf')).toBeInTheDocument();
    });

    it('renders title', () => {
      const { container } = render(
        <ChartBox {...defaultProps} title="My Custom Title" />
      );

      expect(container.textContent).toContain('My Custom Title');
    });
  });

  describe('chart types', () => {
    it('renders DonutChart when type is donut', () => {
      const { container } = render(
        <ChartBox
          {...defaultProps}
          type="donut"
          status="RESOLVED"
          chart={{ id: 'test', data: [['Item', 5]] }}
        />
      );

      // DonutChart renders with donut-chart-pf class
      expect(container.querySelector('.donut-chart-pf')).toBeInTheDocument();
    });

    it('renders BarChart when type is bar', () => {
      const { container } = render(
        <ChartBox
          {...defaultProps}
          type="bar"
          status="RESOLVED"
          chart={{ id: 'test', data: [['Item', 5]] }}
        />
      );

      // BarChart should render (mocked)
      expect(screen.getByTestId('bar-chart')).toBeInTheDocument();
      expect(
        container.querySelector('.donut-chart-pf')
      ).not.toBeInTheDocument();
    });
  });

  describe('modal functionality', () => {
    it('renders chart title in the component', () => {
      const { container } = render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          chart={{ id: 'test', data: [['Item', 5]] }}
        />
      );

      expect(container.textContent).toContain('Test Chart Title');
    });

    it('title has onClick handler when there is data', () => {
      const { container } = render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          chart={{ id: 'test', data: [['Item', 5]] }}
        />
      );

      // Title should have tooltip attribute when there's data
      const titleWithTooltip = container.querySelector(
        '[data-toggle="tooltip"]'
      );
      expect(titleWithTooltip).toBeInTheDocument();
    });

    it('title does not have onClick handler when there is no data', () => {
      const { container } = render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          chart={{ id: 'test', data: [] }}
        />
      );

      // When no data, the title should not have tooltip attribute
      const titleWithTooltip = container.querySelector(
        '[data-toggle="tooltip"]'
      );
      expect(titleWithTooltip).not.toBeInTheDocument();
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

    it('uses provided config for donut chart', () => {
      const { container } = render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          config="large"
          chart={{ id: 'test', data: [['Item', 5]] }}
        />
      );

      expect(container.querySelector('.donut-chart-pf')).toBeInTheDocument();
    });

    it('renders with searchUrl in chart data', () => {
      const { container } = render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          chart={{
            id: 'test',
            data: [['Item', 5]],
            search: '/hosts?search=~VAL~',
          }}
        />
      );

      expect(container.querySelector('.donut-chart-pf')).toBeInTheDocument();
    });

    it('renders no data message when chart has no data', () => {
      const { container } = render(
        <ChartBox
          {...defaultProps}
          status="RESOLVED"
          chart={{ id: 'test', data: [] }}
          noDataMsg="No data available"
        />
      );

      expect(container.textContent).toContain('No data available');
    });
  });
});
