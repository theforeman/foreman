import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';

import EditorModal from '../EditorModal';
import { editorOptions } from '../../Editor.fixtures';

const fixtures = {
  default: {
    ...editorOptions,
    editorValue: '</>',
    onHide: jest.fn(),
    isMaximized: true,
  },
  diff: {
    ...editorOptions,
    selectedView: 'diff',
    editorValue: '</>',
    onHide: jest.fn(),
    isMaximized: true,
  },
};

describe('EditorModal', () => {
  describe('rendering', () => {
    it('renders EditorModal editor', () => {
      render(<EditorModal {...fixtures.default} />)
      const modal = document.querySelector('#editor-modal');

      expect(modal).toBeInTheDocument();
      expect(document.querySelector('.input.monokai')).toBeInTheDocument();
    })
    it('renders diff view with real components', () => {
      render(<EditorModal {...fixtures.diff} />);

      const modal = document.querySelector('#editor-modal');
      expect(modal).toBeInTheDocument();

      expect(document.querySelector('.diff.monokai')).toBeInTheDocument();
      expect(document.querySelector('#diff-table')).toBeInTheDocument();
    });
  })
});
