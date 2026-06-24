import React from 'react';
import { screen, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import { rtlHelpers } from '../../../../common/rtlTestHelpers';
import DiffModal from '../DiffModal';
import ConnectedDiffModal from '../index';
import { createDiff } from '../DiffModalActions';
import { diffModalMock } from '../DiffModal.fixtures';

const toggleModal = jest.fn();
const changeViewType = jest.fn();
const defaultProps = {
  ...diffModalMock,
  toggleModal,
  changeViewType,
};

describe('DiffModal', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('rendering', () => {
    it('renders modal with title and close button', () => {
      rtlHelpers.renderWithStore(<DiffModal {...defaultProps} />);

      expect(screen.getByText('log1')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Close' })).toBeInTheDocument();
    });

    it('uses fallback title when title is empty', () => {
      rtlHelpers.renderWithStore(<DiffModal {...defaultProps} title="" />);

      expect(screen.getByText('Show Diff')).toBeInTheDocument();
    });

    it('renders split and unified view toggles', () => {
      rtlHelpers.renderWithStore(<DiffModal {...defaultProps} />);

      expect(screen.getByRole('button', { name: 'Split' })).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: 'Unified' })
      ).toBeInTheDocument();
    });
  });

  describe('interactions', () => {
    it('calls toggleModal when close button is clicked', async () => {
      rtlHelpers.renderWithStore(<DiffModal {...defaultProps} />);
      const closeButton = screen.getByRole('button', { name: 'Close' });

      await act(async () => fireEvent.click(closeButton));

      expect(toggleModal).toHaveBeenCalled();
    });

    it('calls changeViewType when unified view is selected', async () => {
      rtlHelpers.renderWithStore(<DiffModal {...defaultProps} />);

      await act(async () =>
        fireEvent.click(screen.getByRole('button', { name: 'Unified' }))
      );

      expect(changeViewType).toHaveBeenCalledWith('unified');
    });
  });

  describe('connected component', () => {
    it('opens modal when createDiff is dispatched', () => {
      const { store } = rtlHelpers.renderWithStore(<ConnectedDiffModal />);

      store.dispatch(createDiff(diffModalMock.diff, diffModalMock.title));

      expect(screen.getByText('log1')).toBeInTheDocument();
      expect(screen.getByRole('dialog')).toBeInTheDocument();
    });
  });
});
