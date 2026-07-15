import React from 'react';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { rtlHelpers } from '../../../common/rtlTestHelpers';

import Editor from '../Editor';
import { editorOptions } from '../Editor.fixtures';

const { renderWithI18n } = rtlHelpers;

const renderEditor = (props = {}) => {
  const initializeEditor = jest.fn();

  return {
    initializeEditor,
    ...renderWithI18n(
      <Editor {...editorOptions} initializeEditor={initializeEditor} {...props} />
    ),
  };
};

describe('Editor', () => {
  it('renders editor tabs', async () => {
    renderEditor();

    expect(await screen.findByRole('tab', { name: 'Editor' })).toBeInTheDocument();
    expect(screen.getByRole('tab', { name: 'Changes' })).toBeInTheDocument();
    expect(screen.getByRole('tab', { name: 'Preview' })).toBeInTheDocument();
  });

  it('calls initializeEditor on mount', async () => {
    const { initializeEditor } = renderEditor();

    await screen.findByRole('tab', { name: 'Editor' });

    expect(initializeEditor).toHaveBeenCalledTimes(1);
    expect(initializeEditor).toHaveBeenCalledWith(
      expect.objectContaining({
        selectedView: editorOptions.selectedView,
        template: editorOptions.data.template,
      })
    );
  });

  it('selects the input tab by default', async () => {
    renderEditor({ selectedView: 'input' });

    expect(await screen.findByRole('tab', { name: 'Editor' })).toHaveAttribute(
      'aria-selected',
      'true'
    );
  });

  it('selects the diff tab when diff view is active', async () => {
    renderEditor({ selectedView: 'diff' });

    expect(await screen.findByRole('tab', { name: 'Changes' })).toHaveAttribute(
      'aria-selected',
      'true'
    );
  });

  it('selects the preview tab when preview view is active', async () => {
    renderEditor({ selectedView: 'preview', isRendering: true });

    expect(await screen.findByRole('tab', { name: 'Preview' })).toHaveAttribute(
      'aria-selected',
      'true'
    );
  });

  it('shows the diff table when diff view is active', async () => {
    renderEditor({
      selectedView: 'diff',
      data: { ...editorOptions.data, template: 'old template' },
      value: 'new value',
    });

    expect(await screen.findByRole('tab', { name: 'Changes' })).toHaveAttribute(
      'aria-selected',
      'true'
    );
    expect(screen.getByText('old template')).toBeInTheDocument();
    expect(screen.getAllByText('new value').length).toBeGreaterThan(0);
  });

  it('shows outdated preview warning', async () => {
    renderEditor({
      selectedView: 'preview',
      previewResult: 'rendered preview',
      renderedEditorValue: 'old rendered value',
      value: 'current value',
    });

    expect(await screen.findByText('Preview is outdated.')).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: 'Preview' })
    ).toBeInTheDocument();
  });

  it('refreshes preview when outdated preview link is clicked', async () => {
    const previewTemplate = jest.fn();

    renderEditor({
      previewTemplate,
      selectedView: 'preview',
      previewResult: 'rendered preview',
      renderedEditorValue: 'old rendered value',
      value: 'current value',
      selectedHost: { id: '1', name: 'host1' },
      data: {
        ...editorOptions.data,
        safemodeRenderPath: '/safemode/path',
      },
    });

    userEvent.click(
      await screen.findByRole('button', { name: 'Preview' })
    );

    expect(previewTemplate).toHaveBeenCalledWith({
      host: { id: '1', name: 'host1' },
      renderPath: '/safemode/path',
      templateKindId: '',
    });
  });

  it('dismisses the preview error toast', async () => {
    const dismissErrorToast = jest.fn();

    renderEditor({ dismissErrorToast, showError: true, errorText: 'Preview failed' });

    userEvent.click(await screen.findByRole('button', { name: /Close/i }));

    expect(dismissErrorToast).toHaveBeenCalledTimes(1);
  });

  it('renders the hidden value textarea when editable', async () => {
    renderEditor({ readOnly: false, value: 'editor value' });

    await screen.findByRole('tab', { name: 'Editor' });

    expect(screen.getByDisplayValue('editor value')).toBeInTheDocument();
  });

  it('hides the value textarea when read only', async () => {
    const initializeEditor = jest.fn();
    const { rerender } = renderWithI18n(
      <Editor
        {...editorOptions}
        initializeEditor={initializeEditor}
        readOnly={false}
        value="editor value"
      />
    );

    await screen.findByRole('tab', { name: 'Editor' });
    expect(screen.getByDisplayValue('editor value')).toBeInTheDocument();

    rerender(
      <Editor
        {...editorOptions}
        initializeEditor={initializeEditor}
        readOnly
        value="editor value"
      />
    );

    expect(screen.queryByDisplayValue('editor value')).not.toBeInTheDocument();
  });
});
