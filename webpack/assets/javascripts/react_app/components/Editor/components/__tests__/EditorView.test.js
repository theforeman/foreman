import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import EditorView from '../EditorView';
import { editor } from '../../Editor.fixtures';

jest.mock('react-ace', () => {
  const MockAceEditor = props => (
    <div
      data-testid="ace-editor"
      data-mode={props.mode}
      data-theme={props.theme}
      data-keyboard-handler={props.keyboardHandler}
      data-read-only={props.readOnly}
      data-enable-basic-autocompletion={props.enableBasicAutocompletion}
      data-enable-live-autocompletion={props.enableLiveAutocompletion}
      className={props.className}
    >
      {props.value}
    </div>
  );
  MockAceEditor.displayName = 'MockAceEditor';
  return MockAceEditor;
});

jest.mock('ace-builds/src-min-noconflict/ext-searchbox', () => {});

const defaultProps = {
  name: editor.name,
  mode: editor.mode,
  theme: editor.theme,
  autocompletion: editor.autocompletion,
  liveAutocompletion: editor.liveAutocompletion,
  keyBinding: editor.keyBinding,
  readOnly: editor.readOnly,
  isMasked: editor.isMasked,
  value: editor.value,
};

const renderEditorView = (props = {}) =>
  render(<EditorView {...defaultProps} {...props} />);

describe('EditorView', () => {
  it('renders the editor with the provided value', () => {
    renderEditorView();

    expect(screen.getByText('value')).toBeInTheDocument();
  });

  it('lowercases mode and theme', () => {
    renderEditorView({ mode: 'Ruby', theme: 'Monokai' });

    const editorEl = screen.getByTestId('ace-editor');
    expect(editorEl).toHaveAttribute('data-mode', 'ruby');
    expect(editorEl).toHaveAttribute('data-theme', 'monokai');
  });

  it('sets keyboard handler to null when keyBinding is Default', () => {
    renderEditorView({ keyBinding: 'Default' });

    expect(screen.getByTestId('ace-editor')).not.toHaveAttribute(
      'data-keyboard-handler'
    );
  });

  it('sets keyboard handler when keyBinding is not Default', () => {
    renderEditorView({ keyBinding: 'Vim', isMasked: true });

    expect(screen.getByTestId('ace-editor')).toHaveAttribute(
      'data-keyboard-handler',
      'vim'
    );
  });

  it('applies mask-editor class when isMasked is true', () => {
    renderEditorView({ isMasked: true });

    expect(screen.getByTestId('ace-editor')).toHaveClass('mask-editor');
  });

  it('does not apply mask-editor class when isMasked is false', () => {
    renderEditorView({ isMasked: false });

    expect(screen.getByTestId('ace-editor')).not.toHaveClass('mask-editor');
  });

  it('applies hidden class when isSelected is false', () => {
    renderEditorView({ isSelected: false });

    expect(screen.getByTestId('ace-editor')).toHaveClass('hidden');
  });

  it('does not apply hidden class when isSelected is true', () => {
    renderEditorView({ isSelected: true });

    expect(screen.getByTestId('ace-editor')).not.toHaveClass('hidden');
  });

  it('applies the custom className when isSelected is true', () => {
    renderEditorView({ className: 'foo', isSelected: true });

    expect(screen.getByTestId('ace-editor')).toHaveClass('foo');
  });

  it('does not apply the custom className when isSelected is false', () => {
    renderEditorView({ className: 'foo', isSelected: false });

    expect(screen.getByTestId('ace-editor')).not.toHaveClass('foo');
  });

  it('passes readOnly to the editor', () => {
    renderEditorView({ readOnly: true });

    expect(screen.getByTestId('ace-editor')).toHaveAttribute(
      'data-read-only',
      'true'
    );
  });

  it('enables autocompletion based on props', () => {
    renderEditorView({ autocompletion: true, liveAutocompletion: true });

    const editorEl = screen.getByTestId('ace-editor');
    expect(editorEl).toHaveAttribute(
      'data-enable-basic-autocompletion',
      'true'
    );
    expect(editorEl).toHaveAttribute(
      'data-enable-live-autocompletion',
      'true'
    );
  });

  it('disables live autocompletion when autocompletion is off', () => {
    renderEditorView({ autocompletion: false, liveAutocompletion: true });

    expect(screen.getByTestId('ace-editor')).toHaveAttribute(
      'data-enable-live-autocompletion',
      'false'
    );
  });
});
