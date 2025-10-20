import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import EditorView from '../EditorView';
import { editor } from '../../Editor.fixtures';

const fixtures = {
  default: editor,
  vimMask: {
    ...editor,
    isMasked: true,
    keyBinding: 'vim',
  },
};

jest.mock('react-ace', () => {
  return function MockReactAce(props) {
    return (
      <div data-testid="react-ace" data-props={JSON.stringify(props)}>
        Mock ReactAce Editor
      </div>
    );
  };
});

describe('EditorView', () => {
  describe('rendering', () => {
    const parseNodeProps = node => JSON.parse(node.getAttribute('data-props'));

    it('renders with basic configuration', () => {
      render(<EditorView {...fixtures.default} />);
      const aceEditor = screen.getByTestId('react-ace');

      expect(aceEditor).toBeInTheDocument();

      const props = parseNodeProps(aceEditor);

      expect(props.value).toEqual('value');
      expect(props.mode).toEqual('ruby');
      expect(props.theme).toEqual('monokai');
      expect(props.name).toEqual('editor');
    });
    it('renders with vim and mask configuration', () => {
      render(<EditorView {...fixtures.vimMask} />);
      const aceEditor = screen.getByTestId('react-ace');

      expect(aceEditor).toBeInTheDocument();

      const props = parseNodeProps(aceEditor);

      expect(props.className).toEqual('mask-editor');
      expect(props.keyboardHandler).toEqual('vim');

      expect(props.value).toEqual('value');
      expect(props.mode).toEqual('ruby');
      expect(props.theme).toEqual('monokai');

      expect(props.enableBasicAutocompletion).toBe(true);
      expect(props.enableLiveAutocompletion).toBe(false);
    });
  });
});
