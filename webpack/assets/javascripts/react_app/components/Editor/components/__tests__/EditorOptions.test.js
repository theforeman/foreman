import React from 'react';
import { render, screen, fireEvent, configure } from '@testing-library/react';
import '@testing-library/jest-dom';

import EditorOptions from '../EditorOptions';
import { editorOptions, showBooleans } from '../../Editor.fixtures';

jest.mock('../EditorSettings', () => () => (
  <div data-ouia-component-id="editor-settings" />
));

jest.mock('../../../DiffView/DiffToggle', () => ({ changeState }) => (
  <button
    type="button"
    data-ouia-component-id="diff-toggle"
    onClick={() => changeState('inline')}
  >
    diff
  </button>
));

configure({ testIdAttribute: 'data-ouia-component-id' });

const baseProps = {
  ...editorOptions,
  ...showBooleans,
  isDiff: true,
  changeTab: jest.fn(),
  revertChanges: jest.fn(),
  importFile: jest.fn(),
  toggleModal: jest.fn(),
};

describe('EditorOptions', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    window.confirm = jest.fn(() => true);
  });

  it('renders editor option controls', () => {
    render(<EditorOptions {...baseProps} />);

    expect(document.getElementById('editor-dropdowns')).toBeInTheDocument();
    expect(screen.getByTestId('editor-settings')).toBeInTheDocument();
    expect(screen.getByTestId('revert-local-changes-button')).toBeInTheDocument();
    expect(screen.getByTestId('maximize-editor-button')).toBeInTheDocument();
  });

  it('shows diff toggle when diff view is selected', () => {
    render(<EditorOptions {...baseProps} selectedView="diff" />);

    expect(screen.getByTestId('diff-toggle')).toBeInTheDocument();
  });

  it('hides diff toggle when not on diff view', () => {
    render(<EditorOptions {...baseProps} selectedView="input" />);
    expect(screen.queryByTestId('diff-toggle')).not.toBeInTheDocument();
  });

  it('hides import button when showImport is false', () => {
    render(<EditorOptions {...baseProps} showImport={false} />);

    expect(screen.queryByTestId('import-file-button')).not.toBeInTheDocument();
  });

  it('disables revert when there are no local changes', () => {
    render(<EditorOptions {...baseProps} isDiff={false} />);

    expect(screen.getByTestId('revert-local-changes-button')).toBeDisabled();
  });

  it('reverts changes and switches to input tab when confirmed', () => {
    render(
      <EditorOptions
        {...baseProps}
        selectedView="diff"
        template="local template"
      />
    );

    fireEvent.click(screen.getByTestId('revert-local-changes-button'));

    expect(window.confirm).toHaveBeenCalledTimes(1);
    expect(baseProps.revertChanges).toHaveBeenCalledWith('local template');
    expect(baseProps.changeTab).toHaveBeenCalledWith('input');
  });

  it('opens the file dialog when import is clicked', () => {
    const click = jest.fn();
    render(<EditorOptions {...baseProps} selectedView="input" />);

    const fileInput = document.querySelector('#import-btn input[type="file"]');
    fileInput.click = click;

    fireEvent.click(screen.getByTestId('import-file-button'));

    expect(click).toHaveBeenCalledTimes(1);
  });

  it('calls toggleModal when maximize is clicked', () => {
    render(<EditorOptions {...baseProps} />);

    fireEvent.click(screen.getByTestId('maximize-editor-button'));

    expect(baseProps.toggleModal).toHaveBeenCalledTimes(1);
  });
});
