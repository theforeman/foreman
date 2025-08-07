import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { BackendSystemStatus } from '../index';

const mockPingData = {
  foreman: {
    database: {
      active: true,
      duration_ms: '0'
    },
    cache: {
      servers: [
        {
          status: 'ok',
          duration_ms: '1'
        }
      ]
    }
  },
  foreman_rh_cloud: {
    services: {
      advisor: {
        status: 'FAIL',
        message: '502 Bad Gateway'
      },
      vulnerability: {
        status: 'ok',
        duration_ms: '25'
      }
    },
    status: 'FAIL'
  }
};

const mockPingDataAllOK = {
  foreman: {
    database: {
      active: true,
      duration_ms: '0'
    },
    cache: {
      servers: [
        {
          status: 'ok',
          duration_ms: '1'
        }
      ]
    }
  }
};

describe('BackendSystemStatus', () => {
  it('renders component structure with failed services correctly', () => {
    const { container } = render(<BackendSystemStatus ping={mockPingData} />);
    
    // Basic structure
    expect(screen.getByText('Backend system status')).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: 'Service name' })).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: 'Info' })).toBeInTheDocument();
    
    // Service hierarchy
    expect(screen.getAllByText('foreman')[0]).toBeInTheDocument();
    expect(screen.getByText('database')).toBeInTheDocument();
    expect(screen.getByText('cache')).toBeInTheDocument();
    expect(screen.getByText('servers')).toBeInTheDocument();
    
    // Nested services
    expect(screen.getAllByText('foreman_rh_cloud')[0]).toBeInTheDocument();
    expect(screen.getByText('advisor')).toBeInTheDocument();
    expect(screen.getByText('vulnerability')).toBeInTheDocument();
    
    // Status information
    expect(screen.getByText('active')).toBeInTheDocument();
    expect(screen.getAllByText('true')[0]).toBeInTheDocument();
    expect(screen.getAllByText('duration (ms)')[0]).toBeInTheDocument();
    expect(screen.getByText('FAIL')).toBeInTheDocument();
    expect(screen.getByText('502 Bad Gateway')).toBeInTheDocument();
    
    // Warning icon due to failures
    const warningIcon = container.querySelector('.pf-v5-c-icon__content.pf-m-warning');
    expect(warningIcon).toBeInTheDocument();
    
    // CSS classes
    const parentServiceElements = container.querySelectorAll('.service-name-parent');
    expect(parentServiceElements.length).toBeGreaterThan(0);
    
    // OUIA attributes
    const mainCard = container.querySelector('[data-ouia-component-id="backend-system-status"]');
    expect(mainCard).toBeInTheDocument();
  });

  it('shows success status when all services are OK', () => {
    const { container } = render(<BackendSystemStatus ping={mockPingDataAllOK} />);
    
    const successIcon = container.querySelector('.pf-v5-c-icon__content.pf-m-success');
    expect(successIcon).toBeInTheDocument();
  });

  it('handles edge cases gracefully', () => {
    // Empty data
    const { rerender } = render(<BackendSystemStatus ping={{}} />);
    expect(screen.getByText('Backend system status')).toBeInTheDocument();
    const emptyTableRows = screen.getAllByRole('row');
    expect(emptyTableRows).toHaveLength(1); // Only header row
    
    // Undefined prop
    rerender(<BackendSystemStatus />);
    expect(screen.getByText('Backend system status')).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: 'Service name' })).toBeInTheDocument();
  });
});
