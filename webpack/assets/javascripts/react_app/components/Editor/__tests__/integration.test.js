import React from 'react';
import { act, screen, fireEvent } from '@testing-library/react';
import { rtlHelpers } from '../../../common/testHelpers';
import '@testing-library/jest-dom/extend-expect';

import { editorOptions, serverRenderResponse } from '../Editor.fixtures';
import Editor, { reducers } from '../index';
import * as EditorActions from '../EditorActions'
import { API } from '../../../redux/API';

jest.mock('react-ace', () => {
  return function MockReactAce(props) {
    return (
      <textarea
        data-testid="mock-ace-editor"
        value={props.value}
        onChange={(e) => props.onChange && props.onChange(e.target.value)}
        onBlur={props.onBlur}
        onFocus={props.onFocus}
      />
    );
  };
});

describe('Editor integration test', () => {
  it('should flow', async () => {
    jest
      .spyOn(API, 'get')
      .mockImplementation(async () => ({ data: [] }));
    jest
      .spyOn(EditorActions, 'fetchTemplatePreview')
      .mockImplementation(async () => serverRenderResponse);

    const { container } = rtlHelpers.renderWithStore(
      <Editor {...editorOptions} />
    );

    const previewBtn = screen.getByText('Preview');
    const previewTab = previewBtn.parentElement.parentElement;
    await act(async () => await fireEvent.click(previewBtn));

    expect(previewTab).toHaveClass('pf-m-current');

    const fullscreenBtn = container.querySelector('#fullscreen-btn');
    expect(fullscreenBtn).toBeInTheDocument();
    await act(async () => await fireEvent.click(fullscreenBtn));

    expect(document.querySelector('.pf-v5-c-modal-box')).toBeInTheDocument();
  });
});
