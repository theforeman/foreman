import React from 'react';
import { act } from '@testing-library/react';
import { mount } from 'enzyme';
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
  jest.useFakeTimers();
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(Editor, fixtures));

  describe('triggering', () => {
    it('should trigger input view', async () => {
      const props = { ...editorOptions, ...didMountStubs() };
      const component = mount(<Editor {...props} />);
      await act(async () => jest.advanceTimersByTime(1000));
      expect(
        component
          .find('li[role="presentation"]')
          .at(0)
          .hasClass('active')
      ).toBe(true);
    });
    it('should trigger input view with no template', async () => {
      const props = {
        ...editorOptions,
        ...didMountStubs(),
        data: { ...editorOptions.data, template: null },
      };
      const component = mount(<Editor {...props} />);
      await act(async () => jest.advanceTimersByTime(1000));
      expect(component.props().template).toBe('<? />');
    });
    it('should trigger diff view', async () => {
      const props = {
        ...editorOptions,
        ...didMountStubs(),
        selectedView: 'diff',
      };
      const component = mount(<Editor {...props} />);
      await act(async () => jest.advanceTimersByTime(1000));
      expect(
        component
          .find('li[role="presentation"]')
          .at(1)
          .hasClass('active')
      ).toBe(true);
    });
    it('should trigger preview view', async () => {
      const props = {
        ...editorOptions,
        ...didMountStubs(),
        selectedView: 'preview',
        isRendering: true,
      };
      const wrapper = mount(<Editor {...props} />);
      wrapper.find('button.close').simulate('click');
      await act(async () => jest.advanceTimersByTime(1000));
      const component = mount(<Editor {...props} />);
      await act(async () => jest.advanceTimersByTime(1000));

      expect(
        component
          .find('li[role="presentation"]')
          .at(2)
          .hasClass('active')
      ).toBe(true);
    });
  });
  it('should trigger hidden value editor', async () => {
    const props = {
      ...editorOptions,
      ...didMountStubs(),
      selectedView: 'preview',
      isRendering: true,
      isMasked: true,
    };
    const wrapper = mount(<Editor {...props} />);
    await act(async () => jest.advanceTimersByTime(1000));
    expect(wrapper.find('.mask-editor').exists()).toBe(true);
  });
  it('textarea disappears if readOnly', async () => {
    const props = {
      ...editorOptions,
      ...didMountStubs(),
      selectedView: 'input',
    };
    const wrapper = mount(<Editor {...props} />);
    await act(async () => jest.advanceTimersByTime(1000));
    expect(wrapper.find('textarea.hidden').exists()).toBe(true);
    wrapper.setProps({ readOnly: true });
    expect(wrapper.find('textarea.hidden').exists()).toBe(false);
  });
});
