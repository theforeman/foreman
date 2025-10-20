import React from 'react';
import { render, screen, act, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

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
  renders: editorOptions,
};

const renderEditor = (props = fixtures.renders) =>  render(<Editor {...props} />);

describe('Editor', () => {
  describe('rendering', () => {
    const getAceEditors = () => screen.getAllByRole('textbox', { name: 'Cursor at row 1' })

    it('renders', () => {
      renderEditor();

      expect(screen.getByText('<? />')).toBeInTheDocument();
      expect(getAceEditors().length).toBe(2);
    });
    it('re-renders', () => {
      const { rerender } = renderEditor();
      const props = { ...editorOptions, ...didMountStubs() };
      rerender(<Editor {...props} />);

      expect(getAceEditors().length).toBe(2);
    });
  });
  describe('triggering', () => {
    const getTabById = id =>
      screen.getAllByRole('presentation', { current: "page" })
        .find(tab => (tab.getAttribute('id') || '').match(id));

    it('should trigger input view', async () => {
      const props = { ...editorOptions, ...didMountStubs() };
      renderEditor(props);
      const inputTab = getTabById('input-navitem');

      expect(inputTab).toBeInTheDocument();
      expect(inputTab.parentElement).toHaveClass('pf-m-current');
      expect(inputTab).toHaveTextContent('Editor');
    });
    it('should trigger input view with no template', async () => {
      const props = {
        ...editorOptions,
        ...didMountStubs(),
        data: { ...editorOptions.data, template: null },
      };
      renderEditor(props);
      const aceEditors = document.querySelectorAll('.ace_editor_form');
      const hasTemplateText = Array.from(aceEditors).some(container => container.textContent.includes('<? />'));

      expect(hasTemplateText).toBe(false);
    });
    it('should trigger diff view', async () => {
      const props = {
        ...editorOptions,
        ...didMountStubs(),
        selectedView: 'diff',
      };
      renderEditor(props);
      const diffTab = getTabById('diff-navitem');

      expect(diffTab).toBeInTheDocument();
      expect(diffTab.parentElement).toHaveClass('pf-m-current');
      expect(diffTab).toHaveTextContent('Changes');
    });
    it('should trigger preview view', async () => {
      const props = {
        ...editorOptions,
        ...didMountStubs(),
        selectedView: 'preview',
        isRendering: true,
      };
      renderEditor(props);
      const closeButton = screen.queryByLabelText(/close danger alert/i);

      if (closeButton) await act(async () => await fireEvent.click(closeButton));
      const previewTab = getTabById('preview-navitem');

      expect(previewTab).toBeInTheDocument();
      expect(previewTab.parentElement).toHaveClass('pf-m-current');
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
    renderEditor(props);
    const maskedEditor = document.querySelector('.mask-editor');

    expect(maskedEditor).toBeInTheDocument();
  });
  it('textarea disappears if readOnly', async () => {
    const getTextAreasHidden = () => document.querySelectorAll('textarea.hidden')
    const props = {
      ...editorOptions,
      ...didMountStubs(),
      selectedView: 'input',
      readOnly: false,
    };
    const { rerender } = renderEditor(props);

    expect(getTextAreasHidden().length).toBe(1);

    const newProps = {
      ...props,
      readOnly: true,
    };
    rerender(<Editor {...newProps} />);

    expect(getTextAreasHidden().length).toBe(0);
  });
});
