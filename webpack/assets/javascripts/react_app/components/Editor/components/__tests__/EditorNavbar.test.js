import React from 'react';
import { mount } from '@theforeman/test';
import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

import EditorNavbar from '../EditorNavbar';
import { editorOptions, showBooleans } from '../../Editor.fixtures';

const props = {
  ...editorOptions,
  ...showBooleans,
  isDiff: true,
};

const fixtures = {
  'renders EditorNavbar': props,
};

describe('EditorNavbar', () => {
  describe('rendring', () =>
    testComponentSnapshotsWithFixtures(EditorNavbar, fixtures));

  describe('simulate onClick', () => {
    const changeTab = jest.fn();

    const wrapper = mount(
      <EditorNavbar
        {...props}
        changeTab={changeTab}
        isDiff
        isRendering
        selectedView="preview"
      />
    );
    wrapper
      .find('#input-navitem')
      .at(1)
      .simulate('click');
    wrapper
      .find('#diff-navitem')
      .at(1)
      .simulate('click');

    wrapper.setProps({ ...props, isRendering: false, selectedView: 'input' });
    wrapper.update();
    wrapper
      .find('#preview-navitem')
      .at(1)
      .simulate('click');
    expect(changeTab).toHaveBeenCalledTimes(2);
  });
});
