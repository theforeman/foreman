import React from 'react';
import { mount } from '@theforeman/test';
import { render, fireEvent, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import Editor from '../Editor';
import {
  editorOptions,
  inputEditorContextValue,
  diffEditorContextValue,
  ARIA_SELECTED,
  PF_CURRENT,
} from '../Editor.fixtures';
import { EditorContext } from '../EditorContext';

const didMountStubs = () => ({
  changeState: jest.fn(),
  importFile: jest.fn(),
  revertChanges: jest.fn(),
  previewTemplate: jest.fn(),
  initializeEditor: jest.fn(),
});

describe('Editor', () => {
  describe('triggering', () => {
    it('should trigger input view', () => {
      const props = { ...editorOptions, ...didMountStubs() };
      const component = mount(<Editor {...props} />);

      expect(
        component
          .find('button[role="tab"]')
          .at(0)
          .prop(ARIA_SELECTED)
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
    it('should trigger diff view', async () => {
      const props = {
        ...editorOptions,
        ...didMountStubs(),
      };
      const { getByText, unmount } = await render(<Editor {...props} />);

      // expect 3 tabs to be rendered
      expect(screen.getAllByRole('tab').length).toBe(3);

      // input tab should be selected in initial render
      const inputButton = getByText(/editor/i);
      const inputButtonContainer = inputButton.parentElement.parentElement;
      expect(inputButtonContainer.classList.contains(PF_CURRENT)).toBe(true);

      // click on the changes tab
      // Then, insure the changes tab is selected & the input tab is not selected
      const changesButton = getByText(/changes/i);
      fireEvent.click(changesButton);

      const changesButtonContainer = changesButton.parentElement.parentElement;
      expect(changesButtonContainer.classList.contains(PF_CURRENT)).toBe(true);
      expect(inputButtonContainer.classList.contains(PF_CURRENT)).toBe(false);

      unmount();
    });
    it('should trigger preview view', async () => {
      const props = {
        ...editorOptions,
        ...didMountStubs(),
      };
      const { getByText, unmount } = await render(<Editor {...props} />);

      // expect 3 tabs to be rendered
      expect(screen.getAllByRole('tab').length).toBe(3);

      // input tab should be selected in initial render
      const inputButton = getByText(/editor/i);
      const inputButtonContainer = inputButton.parentElement.parentElement;
      expect(inputButtonContainer.classList.contains(PF_CURRENT)).toBe(true);

      // click on the preview tab
      // Then, insure the preview tab is selected & the input tab is not selected
      const previewButton = getByText(/preview/i);
      fireEvent.click(previewButton);

      const previewButtonContainer = previewButton.parentElement.parentElement;
      expect(previewButtonContainer.classList.contains(PF_CURRENT)).toBe(true);
      expect(inputButtonContainer.classList.contains(PF_CURRENT)).toBe(false);

      unmount();
    });
  });
  it('should trigger hidden value editor', () => {
    const props = {
      ...editorOptions,
      ...didMountStubs(),
      isRendering: true,
      isMasked: true,
    };
    const wrapper = mount(<Editor {...props} />);
    // click on the preview tab:
    const previewButton = wrapper.find('button[role="tab"]').at(2);
    previewButton.simulate('click');

    expect(wrapper.find('.mask-editor').exists()).toBe(true);
  });
  it('textarea disappears if readOnly', () => {
    const props = {
      ...editorOptions,
      ...didMountStubs(),
    };
    const wrapper = mount(<Editor {...props} />);
    expect(wrapper.find('textarea.hidden').exists()).toBe(true);
    wrapper.setProps({ readOnly: true });
    expect(wrapper.find('textarea.hidden').exists()).toBe(false);
  });

  /**********************************************************/

  describe('EditorModal', () => {
    it('should open modal with input view', async () => {
      const toggleModal = jest.fn();

      const { getByLabelText, unmount } = await render(
        <EditorContext.Provider value={inputEditorContextValue}>
          <Editor
            {...editorOptions}
            toggleModal={toggleModal}
            isMaximized={false}
          />
        </EditorContext.Provider>
      );

      const openModalButton = getByLabelText(/Open Modal/i);

      expect(toggleModal).toHaveBeenCalledTimes(0);

      fireEvent.click(openModalButton);

      expect(toggleModal).toHaveBeenCalledTimes(1);

      unmount();
    });

    it('should open modal with diff view', async () => {
      const toggleModal = jest.fn();

      const { getByLabelText, unmount } = await render(
        <EditorContext.Provider value={diffEditorContextValue}>
          <Editor
            {...editorOptions}
            toggleModal={toggleModal}
            isMaximized={false}
          />
        </EditorContext.Provider>
      );

      const openModalButton = getByLabelText(/Open Modal/i);

      expect(toggleModal).toHaveBeenCalledTimes(0);

      fireEvent.click(openModalButton);

      expect(toggleModal).toHaveBeenCalledTimes(1);

      unmount();
    });

    it('should close modal with input view', async () => {
      const toggleModal = jest.fn();

      const { getByLabelText, unmount } = await render(
        <EditorContext.Provider value={inputEditorContextValue}>
          <Editor
            {...editorOptions}
            toggleModal={toggleModal}
            isMaximized={true}
          />
        </EditorContext.Provider>
      );

      const closeModalButton = getByLabelText(/close/i);

      expect(toggleModal).toHaveBeenCalledTimes(0);

      fireEvent.click(closeModalButton);

      expect(toggleModal).toHaveBeenCalledTimes(1);

      unmount();
    });
  });
});
