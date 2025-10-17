import React from 'react';
import { screen, render } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';


import ExportButton from './ExportButton';

const fixtures = {
  renders: {},
  withProps: { url: 'url', title: 'title info', text: 'info' },
};

describe('ExportButton', () => {
  it('renders', () => {
    render(<ExportButton />)
    expect(screen.getByRole('link', { name: "Export" })).toBeInTheDocument();
  });
  it('renders with props', () => {
    render(<ExportButton {...fixtures.withProps} />)
    const button = screen.getByRole('link', { name: "info" });
    expect(button).toBeInTheDocument();
    expect(button).toHaveAttribute('href', 'url');
    expect(button).toHaveAttribute('title', 'title info');
  })
});
