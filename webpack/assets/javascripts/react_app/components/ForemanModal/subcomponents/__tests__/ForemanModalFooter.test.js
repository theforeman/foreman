import React from 'react';
import { screen, fireEvent, render, act } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import ForemanModalFooter from '../ForemanModalFooter';
import * as ModalContext from '../../ForemanModalHooks'; // so enzyme test works

const fixtures = {
  renders: {
    title: 'foo',
  },
  withCustomChildren: {
    title: 'ignored',
    children: <h4>Modal Footer</h4>,
  }
};

const contextValues = {
  onClose: jest.fn(),
};

jest
  .spyOn(ModalContext, 'useModalContext')
  .mockImplementation(() => contextValues);

describe('ForemanModal.Footer', () => {
  describe('rendering', () => {
    it('should show Close when onClose is provided', () => {
      render(<ForemanModalFooter {...fixtures.renders} />);
      expect(screen.getByRole('button', { name: /close/i })).toBeInTheDocument();
    });

    it('should render custom children when provided', () => {
      render(<ForemanModalFooter {...fixtures.withCustomChildren} />);
      expect(screen.getByText('Modal Footer')).toBeInTheDocument();
    });
  });

  describe('data flow', () => {
    it('should call onClose available through context', async () => {
      render(<ForemanModalFooter {...fixtures.renders} />);
      await act( async () => await fireEvent.click(screen.getByRole('button', { name: /close/i })));
      expect(contextValues.onClose).toHaveBeenCalled();
    });

    it('passes props to PF component using spread', () => {
      const { container } = render(<ForemanModalFooter className="custom-class" />);
      const modalFooter = container.querySelector('.modal-footer');
      expect(modalFooter).toHaveClass('custom-class');
    });
  });
});
