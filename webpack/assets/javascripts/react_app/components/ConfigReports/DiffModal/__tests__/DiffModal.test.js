import React from 'react';
import { screen, fireEvent, render, act } from '@testing-library/react';
import { configure } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import DiffModal from '../DiffModal';
import { diffModalMock } from '../DiffModal.fixtures';

const toggleModal = jest.fn();
const changeState = jest.fn();
const fixtures = {
  renders: {
    ...diffModalMock,
    toggleModal: toggleModal,
    changeViewType: changeState,
  },
};
configure({ testIdAttribute: 'data-ouia-component-id'})

describe('DiffModal', () => {
  describe('rendering', () => {
      it('should render modal with title and close button', () => {
        render(<DiffModal {...fixtures.renders} />);

        expect(screen.getByText('log1')).toBeInTheDocument();
        const closeButton = document.querySelector('.diff-modal-close');
        expect(closeButton).toBeInTheDocument();
        expect(closeButton).toHaveClass('close', 'diff-modal-close');
      });
  });

  describe('triggering..', () => {
    it('should trigger onHide', async () => {
      render(<DiffModal {...fixtures.renders} />);
      const closeButton = screen.getByTestId('diff-modal-close-button');

      await act(async () => await fireEvent.click(closeButton));

      expect(toggleModal).toHaveBeenCalled();
    });
  });
});
