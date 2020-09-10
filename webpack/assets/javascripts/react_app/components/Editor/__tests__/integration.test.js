import React from 'react';

import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

import { editorOptions, serverRenderResponse } from '../Editor.fixtures';
import Editor, { reducers } from '../index';
import * as EditorActions from '../EditorActions';

jest.mock('../../../redux/API');

describe('Editor integration test', () => {
  it('should flow', () => {
    jest
      .spyOn(EditorActions, 'fetchTemplatePreview')
      .mockImplementation(async () => serverRenderResponse);

    const integrationTestHelper = new IntegrationTestHelper(reducers);

    const component = integrationTestHelper.mount(
      <Editor {...editorOptions} />
    );
    integrationTestHelper.takeStoreSnapshot('initial state');

    const previewBtn = component.find('#preview-navitem').at(1);
    previewBtn.simulate('click');

    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'switched to preview view'
    );
    expect(
      component
        .find('li[role="presentation"]')
        .at(2)
        .hasClass('active')
    ).toBe(true);

    IntegrationTestHelper.flushAllPromises();
    component.update();

    const maximizeBtn = component.find('#fullscreen-btn').at(0);
    maximizeBtn.simulate('click');

    integrationTestHelper.takeStoreAndLastActionSnapshot('entered fullscreen');
    expect(component.find('.editor-modal.in').length).toBeGreaterThan(0);
  });
});
