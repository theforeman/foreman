import React from 'react';
import { render, screen, act, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import EditorNavbar from '../EditorNavbar';
import { editorOptions, showBooleans } from '../../Editor.fixtures';

const { data: editorOptionsData, ...restEditorOptions } = editorOptions;

const props = {
  ...editorOptionsData,
  ...restEditorOptions,
  ...showBooleans,
  isDiff: true,
};

describe('EditorNavbar', () => {
  describe('rendering', () => {
    it('renders EditorNavbar', () => {
      render(<EditorNavbar {...props}/>)

      const navbar = screen.getByRole('tablist' );
      expect(navbar).toBeInTheDocument();
      expect(navbar).toHaveClass('pf-v5-c-tabs__list');
    })
  })
  describe('simulate onClick', () => {
    it('handles click correctly', async () => {
      const getTabById = id =>
            screen.getAllByRole('presentation', { current: "page" })
                  .find(tab => (tab.getAttribute('id') || '').match(id));

      const changeTab = jest.fn();

      const { rerender } = render(
        <EditorNavbar
          {...props}
          changeTab={changeTab}
          isDiff
          isRendering
          selectedView="preview"
        />
      );

      const inputTab = getTabById('input-navitem');
      const diffTab = getTabById('diff-navitem');
      await act(async () => await fireEvent.click(inputTab));
      await act(async () => await fireEvent.click(diffTab));

      rerender(
        <EditorNavbar
          {...props}
          changeTab={changeTab}
          isRendering={false}
          selectedView="input"
        />
      );
      const previewTab = getTabById('preview-navitem');
      await act(async () => await fireEvent.click(previewTab));

      expect(changeTab).toHaveBeenCalledTimes(3);
    })
  });
});
