import React from 'react';
import { mount } from '@theforeman/test';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import Editor from '../Editor';
import { editorOptions } from '../Editor.fixtures';

const didMountStubs = () => ({
  changeState: jest.fn(),
  importFile: jest.fn(),
  revertChanges: jest.fn(),
  previewTemplate: jest.fn(),
  initializeEditor: jest.fn(),
});

const fixtures = {
  'renders editor': editorOptions,
};

describe('Editor', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(Editor, fixtures));

  describe('triggering', () => {
    it('should trigger input view', () => {
      const props = { ...editorOptions, ...didMountStubs() };
      const component = mount(<Editor {...props} />);

      expect(
        component
          .find('li[role="presentation"]')
          .at(0)
          .hasClass('active')
      ).toBe(true);
    });
    it('should trigger input view with no template', () => {
      const props = {
        ...editorOptions,
        ...didMountStubs(),
        data: { ...editorOptions.data, template: null },
      };
      const component = mount(<Editor {...props} />);
      expect(component.props().template).toBe('<? />');
    });
    it('should trigger diff view', () => {
      const props = {
        ...editorOptions,
        ...didMountStubs(),
        selectedView: 'diff',
      };
      const component = mount(<Editor {...props} />);

      expect(
        component
          .find('li[role="presentation"]')
          .at(1)
          .hasClass('active')
      ).toBe(true);
    });
    it('should trigger preview view', () => {
      const props = {
        ...editorOptions,
        ...didMountStubs(),
        selectedView: 'preview',
        isRendering: true,
      };
      const wrapper = mount(<Editor {...props} />);
      wrapper.find('button.close').simulate('click');

      const component = mount(<Editor {...props} />);

      expect(
        component
          .find('li[role="presentation"]')
          .at(2)
          .hasClass('active')
      ).toBe(true);
    });
  });
  it('should trigger hidden value editor', () => {
    const props = {
      ...editorOptions,
      ...didMountStubs(),
      selectedView: 'preview',
      isRendering: true,
      isMasked: true,
    };
    const wrapper = mount(<Editor {...props} />);
    expect(wrapper.find('.mask-editor').exists()).toBe(true);
  });
  it('textarea disappears if readOnly', () => {
    const props = {
      ...editorOptions,
      ...didMountStubs(),
      selectedView: 'input',
    };
    const wrapper = mount(<Editor {...props} />);
    expect(wrapper.find('textarea.hidden').exists()).toBe(true);
    wrapper.setProps({ readOnly: true });
    expect(wrapper.find('textarea.hidden').exists()).toBe(false);
  });
});
