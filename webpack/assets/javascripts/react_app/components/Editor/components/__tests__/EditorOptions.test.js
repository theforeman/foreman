import React from 'react';
import { render, screen, act, fireEvent, configure } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import EditorOptions from '../EditorOptions';
import { editorOptions, showBooleans } from '../../Editor.fixtures';

const props = { ...editorOptions, ...showBooleans, isDiff: true };

const fixtures = {
  'renders EditorOptions': props,
};

configure({ testIdAttribute: 'data-ouia-component-id' });

describe('EditorOptions', () => {
  it('renders', () => {
    render(<EditorOptions {...props}/>)
    const editorDropdowns = document.getElementById('editor-options');

    expect(editorDropdowns).toBeInTheDocument();

    const hideButton = screen.getByTestId('hide-content-button');
    expect(hideButton).toBeInTheDocument();
  })
  describe('simulate', () => {
    it('clicks', async () => {
      const toggleMaskValue = jest.fn();
      const changeTab = jest.fn();
      const revertChanges = jest.fn();
      jest.mock('../EditorOptions');
      window.confirm = jest.fn(() => true);

      const { rerender } = render( /* diff view */
        <EditorOptions
          {...props}
          changeTab={changeTab}
          toggleMaskValue={toggleMaskValue}
          revertChanges={revertChanges}
          isDiff
          selectedView="diff"
        />
      );
      const undoButton = screen.getByTestId('revert-local-changes-button');
      await act(async () => await fireEvent.click(undoButton));

      expect(window.confirm).toHaveBeenCalledTimes(1);
      expect(revertChanges).toHaveBeenCalledTimes(1);


      rerender( /* input view */
        <EditorOptions
          {...props}
          changeTab={changeTab}
          toggleMaskValue={toggleMaskValue}
          revertChanges={revertChanges}
          isDiff
        />
      );

      const hideButton = screen.getByTestId('hide-content-button');
      await act(async () => await fireEvent.click(hideButton));

      expect(toggleMaskValue).toHaveBeenCalledTimes(1);

      const importButton = screen.getByTestId('import-file-button');
      await act(async () => await fireEvent.click(importButton));

      expect(changeTab).toHaveBeenCalledTimes(1);
    });
  });
});
