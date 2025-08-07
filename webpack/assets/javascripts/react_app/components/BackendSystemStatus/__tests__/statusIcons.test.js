import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { FailIcon, WarnIcon, OKIcon, StatusValue } from '../statusIcons';

describe('StatusIcons', () => {
  describe('Icon Components', () => {
    it('renders all icon types with correct status classes', () => {
      const { container: failContainer } = render(<FailIcon data-testid="fail-icon" />);
      const { container: warnContainer } = render(<WarnIcon data-testid="warn-icon" />);
      const { container: okContainer } = render(<OKIcon data-testid="ok-icon" />);
      
      expect(failContainer.querySelector('.pf-v5-c-icon__content.pf-m-danger')).toBeInTheDocument();
      expect(warnContainer.querySelector('.pf-v5-c-icon__content.pf-m-warning')).toBeInTheDocument();
      expect(okContainer.querySelector('.pf-v5-c-icon__content.pf-m-success')).toBeInTheDocument();
      
      // Test prop passing
      expect(screen.getByTestId('fail-icon')).toBeInTheDocument();
      expect(screen.getByTestId('warn-icon')).toBeInTheDocument();
      expect(screen.getByTestId('ok-icon')).toBeInTheDocument();
    });
  });

  describe('StatusValue', () => {
    it('renders success values with success icons', () => {
      const successValues = ['OK', 'Ok', 'ok', 'true'];
      
      successValues.forEach((val) => {
        const { container, unmount } = render(<StatusValue val={val} />);
        
        expect(screen.getByText(val)).toBeInTheDocument();
        const icon = container.querySelector('.pf-v5-c-icon__content.pf-m-success');
        expect(icon).toBeInTheDocument();
        
        unmount();
      });
    });

    it('renders failure values with danger icons', () => {
      const failureValues = ['FAIL', 'fail', 'false'];
      
      failureValues.forEach((val) => {
        const { container, unmount } = render(<StatusValue val={val} />);
        
        expect(screen.getByText(val)).toBeInTheDocument();
        const icon = container.querySelector('.pf-v5-c-icon__content.pf-m-danger');
        expect(icon).toBeInTheDocument();
        
        unmount();
      });
    });

    it('renders arbitrary text without icons and handles edge cases', () => {
      const { container, rerender } = render(<StatusValue val="some random text" />);
      
      // Text without icon
      expect(screen.getByText('some random text')).toBeInTheDocument();
      const successIcon = container.querySelector('.pf-v5-c-icon__content.pf-m-success');
      const dangerIcon = container.querySelector('.pf-v5-c-icon__content.pf-m-danger');
      expect(successIcon).not.toBeInTheDocument();
      expect(dangerIcon).not.toBeInTheDocument();
      
      // Numeric values
      rerender(<StatusValue val="123" />);
      expect(screen.getByText('123')).toBeInTheDocument();
      
      // CSS class application
      rerender(<StatusValue val="OK" />);
      const statusElement = container.querySelector('.bss-status-value');
      expect(statusElement).toBeInTheDocument();
      
      // Edge cases
      rerender(<StatusValue val="" />);
      expect(container).toBeInTheDocument();
      
      rerender(<StatusValue />);
      expect(container).toBeInTheDocument();
      
      // Object conversion
      rerender(<StatusValue val={{ status: 'ok' }.toString()} />);
      expect(container).toBeInTheDocument();
    });
  });
});
