import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';

import SubstringWrapper from './';

describe('SubstringWrapper', () => {
  it('wraps the substring in a <b> tag by default', () => {
    const { container } = render(
      <SubstringWrapper substring="test">this is a test</SubstringWrapper>
    );

    expect(container).toHaveTextContent('this is a test');
    const bolds = container.querySelectorAll('b');
    expect(bolds).toHaveLength(1);
    expect(bolds[0]).toHaveTextContent('test');
  });

  it('wraps every occurrence of the substring', () => {
    const { container } = render(
      <SubstringWrapper substring="test">
        test - this is a test
      </SubstringWrapper>
    );

    expect(container).toHaveTextContent('test - this is a test');
    expect(container.querySelectorAll('b')).toHaveLength(2);
  });

  it('wraps the substring with the supplied element', () => {
    const { container } = render(
      <SubstringWrapper Element="i" substring="test">
        this is a test
      </SubstringWrapper>
    );

    expect(container).toHaveTextContent('this is a test');
    const italics = container.querySelectorAll('i');
    expect(italics).toHaveLength(1);
    expect(italics[0]).toHaveTextContent('test');
    expect(container.querySelector('b')).not.toBeInTheDocument();
  });

  it('renders plain text when the substring is not found', () => {
    const { container } = render(
      <SubstringWrapper Element="i" substring="test">
        this is a SubstringWrapper component
      </SubstringWrapper>
    );

    expect(container).toHaveTextContent('this is a SubstringWrapper component');
    expect(container.querySelector('i')).not.toBeInTheDocument();
  });

  it('renders plain text when the substring is an invalid regex', () => {
    const { container } = render(
      <SubstringWrapper substring="*">this is a test</SubstringWrapper>
    );

    expect(container).toHaveTextContent('this is a test');
    expect(container.querySelector('b')).not.toBeInTheDocument();
  });
});
