import React from 'react';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { rtlHelpers } from '../../../../common/rtlTestHelpers';

import EditorNavbar from '../EditorNavbar';
import { editorOptions, showBooleans } from '../../Editor.fixtures';

const { renderWithI18n } = rtlHelpers;

const { data: editorOptionsData, ...restEditorOptions } = editorOptions;

const defaultProps = {
  ...editorOptionsData,
  ...restEditorOptions,
  ...showBooleans,
  isDiff: true,
  safemode: editorOptionsData.isSafemodeEnabled,
  selectedRenderPath: editorOptionsData.safemodeRenderPath,
  handleSafeModeChange: jest.fn(),
};

const renderNavbar = (props = {}) =>
  renderWithI18n(<EditorNavbar {...defaultProps} {...props} />);

describe('EditorNavbar', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders editor tabs', async () => {
    renderNavbar();

    expect(await screen.findByRole('tab', { name: 'Editor' })).toBeInTheDocument();
    expect(screen.getByRole('tab', { name: 'Changes' })).toBeInTheDocument();
    expect(screen.getByRole('tab', { name: 'Preview' })).toBeInTheDocument();
  });

  it('disables changes tab when there is no diff', async () => {
    renderNavbar({ isDiff: false });

    expect(await screen.findByRole('tab', { name: 'Changes' })).toHaveAttribute(
      'aria-disabled',
      'true'
    );
  });

  it('switches tabs on click', async () => {
    const changeTab = jest.fn();
    const toggleRenderView = jest.fn();

    renderNavbar({
      changeTab,
      toggleRenderView,
      selectedView: 'preview',
      isRendering: true,
    });

    userEvent.click(await screen.findByRole('tab', { name: 'Editor' }));
    userEvent.click(screen.getByRole('tab', { name: 'Changes' }));

    expect(changeTab).toHaveBeenCalledTimes(2);
    expect(changeTab).toHaveBeenNthCalledWith(1, 'input');
    expect(changeTab).toHaveBeenNthCalledWith(2, 'diff');
    expect(toggleRenderView).toHaveBeenCalledTimes(1);
  });

  it('shows host filter on preview tab', async () => {
    renderNavbar({ selectedView: 'preview' });

    expect(
      await screen.findByPlaceholderText('Filter Host...')
    ).toBeInTheDocument();
  });

  it('shows preview loading spinner', async () => {
    renderNavbar({ selectedView: 'preview', isLoading: true });

    await screen.findByRole('tab', { name: 'Preview' });

    expect(screen.getAllByLabelText('Loading')).not.toHaveLength(0);
  });
});
