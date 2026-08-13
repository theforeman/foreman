import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import EditorModal from '../EditorModal';
import { editorOptions } from '../../Editor.fixtures';

jest.mock('react-ace', () => props => (
  <textarea data-testid="ace-editor" defaultValue={props.value} readOnly={props.readOnly} />
));
jest.mock('ace-builds/src-min-noconflict/ext-searchbox', () => {});

const defaultProps = {
  ...editorOptions,
  editorValue: '</>',
  isMaximized: true,
  title: 'Editor Modal Title',
};

describe('EditorModal', () => {
  it('renders the editor view when selectedView is input', () => {
    render(<EditorModal {...defaultProps} />);

    expect(
      screen.getByRole('heading', { name: 'Editor Modal Title' })
    ).toBeInTheDocument();
    expect(screen.getByTestId('ace-editor')).toBeInTheDocument();
    expect(screen.queryByText('Split')).not.toBeInTheDocument();
    expect(screen.queryByText('Unified')).not.toBeInTheDocument();
  });

  it('renders the diff view with toggle buttons when selectedView is diff', () => {
    render(<EditorModal {...defaultProps} selectedView="diff" />);

    expect(
      screen.getByRole('heading', { name: 'Editor Modal Title' })
    ).toBeInTheDocument();
    expect(screen.getByText('Split')).toBeInTheDocument();
    expect(screen.getByText('Unified')).toBeInTheDocument();
    expect(screen.queryByTestId('ace-editor')).not.toBeInTheDocument();
  });

  it('does not render content when modal is closed', () => {
    render(<EditorModal {...defaultProps} isMaximized={false} />);

    expect(
      screen.queryByRole('heading', { name: 'Editor Modal Title' })
    ).not.toBeInTheDocument();
  });
});
