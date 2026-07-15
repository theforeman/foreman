import React from 'react';

import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

import { editorOptions, serverRenderResponse } from '../Editor.fixtures';
import Editor, { reducers } from '../index';
import * as EditorActions from '../EditorActions'

jest.mock('../../../redux/API');

const expectTabSelected = (component, ouiaId) => {
  expect(
    component.find(`[data-ouia-component-id="${ouiaId}"]`).prop('aria-selected')
  ).toBe(true);
};

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

    const previewBtn = component.find('[data-ouia-component-id="preview-navitem"]');
    previewBtn.simulate('click');
    component.update();

    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'switched to preview view'
    );
    expectTabSelected(component, 'preview-navitem');

    IntegrationTestHelper.flushAllPromises();
    component.update();

    const maximizeBtn = component.find('#fullscreen-btn').at(0);
    maximizeBtn.simulate('click');

    integrationTestHelper.takeStoreAndLastActionSnapshot('entered fullscreen');
    expect(component.find('.editor-modal').length).toBeGreaterThan(0);
  });
});
