import React from 'react';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom/extend-expect';

import EditorOptions from '../EditorOptions';
import { editorOptions, showBooleans } from '../../Editor.fixtures';

jest.mock('@patternfly/react-core', () => {
  const actual = jest.requireActual('@patternfly/react-core');

  // PF Tooltip uses Popper, which triggers act() warnings under Jest's console.error hook.
  return {
    ...actual,
    Tooltip: ({ children }) => children,
  };
});

const defaultProps = {
  ...editorOptions,
  ...showBooleans,
  isDiff: true,
  changeTab: jest.fn(),
  revertChanges: jest.fn(),
  toggleModal: jest.fn(),
  importFile: jest.fn(),
  changeDiffViewType: jest.fn(),
};

const renderEditorOptions = (props = {}) =>
  render(<EditorOptions {...defaultProps} {...props} />);

describe('EditorOptions', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('rendering', () => {
    it('renders toolbar action buttons', () => {
      renderEditorOptions();

      expect(
        screen.getByRole('button', { name: 'Revert Local Changes' })
      ).toBeEnabled();
      expect(
        screen.getByRole('button', { name: 'Import File' })
      ).toBeEnabled();
      expect(screen.getByRole('button', { name: 'Maximize' })).toBeEnabled();
    });

    it('renders diff toggle when selectedView is diff', () => {
      renderEditorOptions({ selectedView: 'diff' });

      expect(screen.getByRole('button', { name: 'Split' })).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: 'Unified' })
      ).toBeInTheDocument();
    });

    it('does not render diff toggle when selectedView is input', () => {
      renderEditorOptions({ selectedView: 'input' });

      expect(
        screen.queryByRole('button', { name: 'Split' })
      ).not.toBeInTheDocument();
      expect(
        screen.queryByRole('button', { name: 'Unified' })
      ).not.toBeInTheDocument();
    });

    it('disables revert button when isDiff is false', () => {
      renderEditorOptions({ isDiff: false });

      expect(
        screen.getByRole('button', { name: 'Revert Local Changes' })
      ).toBeDisabled();
    });

    it('disables import button when selectedView is not input', () => {
      renderEditorOptions({ selectedView: 'preview' });

      expect(
        screen.getByRole('button', { name: 'Import File' })
      ).toBeDisabled();
    });

    it('does not render import button when showImport is false', () => {
      renderEditorOptions({ showImport: false });

      expect(
        screen.queryByRole('button', { name: 'Import File' })
      ).not.toBeInTheDocument();
    });
  });

  describe('interactions', () => {
    it('reverts changes and switches tab when revert is confirmed on diff view', () => {
      window.confirm = jest.fn(() => true);
      renderEditorOptions({ selectedView: 'diff' });

      userEvent.click(
        screen.getByRole('button', { name: 'Revert Local Changes' })
      );

      expect(window.confirm).toHaveBeenCalledWith(
        'Are you sure you would like to revert all changes?'
      );
      expect(defaultProps.revertChanges).toHaveBeenCalledWith('<? />');
      expect(defaultProps.changeTab).toHaveBeenCalledWith('input');
    });

    it('does not revert changes when confirmation is cancelled', () => {
      window.confirm = jest.fn(() => false);
      renderEditorOptions({ selectedView: 'diff' });

      userEvent.click(
        screen.getByRole('button', { name: 'Revert Local Changes' })
      );

      expect(window.confirm).toHaveBeenCalledTimes(1);
      expect(defaultProps.revertChanges).not.toHaveBeenCalled();
      expect(defaultProps.changeTab).not.toHaveBeenCalled();
    });

    it('does not switch tab when revert is confirmed on input view', () => {
      window.confirm = jest.fn(() => true);
      renderEditorOptions({ selectedView: 'input' });

      userEvent.click(
        screen.getByRole('button', { name: 'Revert Local Changes' })
      );

      expect(defaultProps.revertChanges).toHaveBeenCalledWith('<? />');
      expect(defaultProps.changeTab).not.toHaveBeenCalled();
    });

    it('calls toggleModal when maximize is clicked', () => {
      renderEditorOptions();

      userEvent.click(screen.getByRole('button', { name: 'Maximize' }));

      expect(defaultProps.toggleModal).toHaveBeenCalledTimes(1);
    });

    it('calls changeDiffViewType when unified view is selected', () => {
      const changeDiffViewType = jest.fn();
      renderEditorOptions({ selectedView: 'diff', changeDiffViewType });

      userEvent.click(screen.getByRole('button', { name: 'Unified' }));

      expect(changeDiffViewType).toHaveBeenCalledWith('unified');
    });

    it('opens the file dialog when import is clicked', () => {
      const clickSpy = jest.spyOn(HTMLInputElement.prototype, 'click');
      renderEditorOptions();

      userEvent.click(screen.getByRole('button', { name: 'Import File' }));

      expect(clickSpy).toHaveBeenCalled();
      clickSpy.mockRestore();
    });

    it('calls importFile when a file is selected', () => {
      renderEditorOptions();
      const file = new File(['template content'], 'template.erb', {
        type: 'text/plain',
      });
      const fileInput = document.querySelector('input[type="file"]');

      userEvent.upload(fileInput, file);

      expect(defaultProps.importFile).toHaveBeenCalled();
    });
  });
});
