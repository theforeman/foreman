// TemplateGenerator.test.jsx
import React from 'react';
import { screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import TemplateGenerator from '../TemplateGenerator';
import { rtlHelpers } from "../../../common/testHelpers";

const fixtures = {
  'render button if not polling and no errors': {
    props: {
      data: { templateName: 'template' },
      polling: false,
      dataUrl: '/data/IDENTIFIER.json',
    },
  },
  'render info alert if polling': {
    props: {
      data: { templateName: 'template' },
      polling: true,
      dataUrl: '/data/IDENTIFIER.json',
    },
  },
  'renders errors if there are some': {
    props: {
      data: { templateName: 'template' },
      polling: false,
      generatingError: '422 unprocessable entity',
      generatingErrorMessages: [
        { message: 'Eh there was no method error during the render :(' },
      ],
    },
  },
};

describe('TemplateGenerator', () => {
  it('renders Download button when not polling and no errors', () => {
    const { props } = fixtures['render button if not polling and no errors'];
    rtlHelpers.renderWithStore(<TemplateGenerator {...props} />);

    // Title is stable regardless of state
    expect(
      screen.getByText('Generating a report')
    ).toBeInTheDocument();

    // Done state -> download button visible
    expect(
      screen.getByRole('link', { name: /download/i })
    ).toBeInTheDocument();

    // Should include the "done" message text
    expect(
      screen.getByText(/Generating of the report template has been completed\./i)
    ).toBeInTheDocument();
  });

  it('renders info alert when polling', () => {
    const { props } = fixtures['render info alert if polling'];
    rtlHelpers.renderWithStore(<TemplateGenerator {...props} />);

    expect(
      screen.getByText('Generating a report')
    ).toBeInTheDocument();

    // Polling message shows
    expect(
      screen.getByText(/Report template is now being generated/i)
    ).toBeInTheDocument();

    // No download button while polling
    expect(screen.queryByRole('button', { name: /download/i })).not.toBeInTheDocument();
  });

  it('renders combined errors when present and hides the button', () => {
    const { props } = fixtures['renders errors if there are some'];
    rtlHelpers.renderWithStore(<TemplateGenerator {...props} />);

    expect(
      screen.getByText(/Eh there was no method error during the render/i)
    ).toBeInTheDocument();

    expect(screen.queryByRole('button', { name: /download/i })).not.toBeInTheDocument();
  });

  it('renders nothing when not polling and no dataUrl', () => {
    const { container } = rtlHelpers.renderWithStore(
      <TemplateGenerator data={{ templateName: 'template' }} polling={false} />
    );
    expect(container.firstChild).toBeNull();
  });
});
