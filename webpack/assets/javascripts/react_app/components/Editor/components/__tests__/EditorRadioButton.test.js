import React from 'react';
import { configure, render, screen } from "@testing-library/react"
import '@testing-library/jest-dom/extend-expect';

import { noop } from '../../../../common/helpers';

import EditorRadioButton from '../EditorRadioButton';
import { editor } from '../../Editor.fixtures';

const fixtures = {
  renders: {
    eventKey: 0,
    stateView: editor.selectedView,
    btnView: editor.selectedView,
    title: 'Editor',
    onClick: noop,
  },
};

configure({ testIdAttribute: 'data-ouia-component-id' });

describe('EditorRadioButton', () => {
  it('renders', () => {
    render(<EditorRadioButton {...fixtures.renders} />);

    const navItem = screen.getByText('Editor');
    expect(navItem).toBeInTheDocument();

    const navItemContainer = screen.getByTestId('input-navitem');
    expect(navItemContainer).toBeInTheDocument();
  })
})
