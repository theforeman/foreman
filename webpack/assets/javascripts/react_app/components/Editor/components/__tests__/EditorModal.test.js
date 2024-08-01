import React from 'react';
import { render, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';

import EditorModal from '../EditorModal';
import {
  EditorModalfixtures,
  inputEditorContextValue,
  diffEditorContextValue,
} from '../../Editor.fixtures';
import { EditorContext } from '../../EditorContext';

describe('EditorModal', () => {
  it('should render with diff view', async () => {
    const changeDiffViewType = jest.fn();

    const { getByText, unmount } = await render(
      <EditorContext.Provider value={diffEditorContextValue}>
        <EditorModal
          {...EditorModalfixtures}
          changeDiffViewType={changeDiffViewType}
        />
      </EditorContext.Provider>
    );

    const splitButton = getByText(/split/i);
    const unifiedButton = getByText(/unified/i);

    fireEvent.click(unifiedButton);
    expect(changeDiffViewType).toHaveBeenCalledWith('unified');

    // changeDiffViewType should only be called once and with unified, because the original render was with split
    // and the component only changes the view type if it is different from the original
    // changeDiffViewType is only a mock here, so it doesn't actually change the view type
    fireEvent.click(splitButton);
    expect(changeDiffViewType).not.toHaveBeenCalledWith('split');

    expect(changeDiffViewType).toHaveBeenCalledTimes(1);

    unmount();
  });

  it('should not render with editor view', async () => {
    const { queryByText, unmount } = await render(
      <EditorContext.Provider value={inputEditorContextValue}>
        <EditorModal {...EditorModalfixtures} />
      </EditorContext.Provider>
    );

    // Should not find these toggle buttons on the screen
    expect(queryByText(/split/i)).toBe(null);
    expect(queryByText(/unified/i)).toBe(null);
    
    unmount();
  });
});
