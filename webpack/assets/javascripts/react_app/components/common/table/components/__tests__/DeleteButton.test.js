import React from 'react';
import { screen, fireEvent, render, act } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import DeleteButton from '../DeleteButton';

const baseProps = {
  id: 1,
  name: 'KVM',
  controller: 'models',
  onClick: () => {},
};

const fixtures = {
  active: {
    active: true,
    ...baseProps,
  },
  inactive: baseProps,
};

describe('DeleteButton', () => {
  describe('when active', () => {
    const props = { ...fixtures.active };

    it('should render delete button', () => {
      render(<DeleteButton {...props} />);

      const deleteButton = screen.getByRole('button', { name: /delete/i });
      expect(deleteButton).toBeInTheDocument();
    });

    it('should have correct button text', () => {
      render(<DeleteButton {...props} />);

      const deleteButton = screen.getByRole('button', { name: /delete/i });
      expect(deleteButton).toHaveTextContent('Delete');
    });

    it('should have secondary variant style', () => {
      render(<DeleteButton {...props} />);

      const deleteButton = screen.getByRole('button', { name: /delete/i });
      expect(deleteButton).toHaveClass('pf-m-secondary');
    });
  });

  describe('when inactive', () => {
    const props = { ...fixtures.inactive };

    it('should not render anything', () => {
      const { container } = render(<DeleteButton {...props} />);

      const button = screen.queryByRole('button', { name: /delete/i });
      expect(button).not.toBeInTheDocument();

      expect(container.firstChild).toBeNull();
    });
  });
});
