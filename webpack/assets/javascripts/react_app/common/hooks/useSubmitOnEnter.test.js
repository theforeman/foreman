import React, { createRef, useState } from 'react';
import useSubmitOnEnter from './useSubmitOnEnter';
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect';

// It's hard to test this hook in isolation since what it returns is not the important part,
// rather that it attaches and removes an event listener properly. Testing within a component
// for this reason.
const TestComponent = ({ phrase }) => {
  const [showPhrase, setShowPhrase] = useState(false);
  const testRef = createRef(null);
  const onSubmit = () => setShowPhrase(!showPhrase);
  useSubmitOnEnter(testRef, onSubmit)

  return (
    <div aria-label={"test-div"} ref={testRef}>
      <p>{ showPhrase ? phrase : ""}</p>
    </div>
  );
}

describe('useSubmitOnEnter', () => {
  it('should attach event listener on mount and use callback on keypress', () => {
    const phrase = "showing!"
    const { unmount, queryByText, getByText, getByLabelText } = render(<TestComponent phrase={phrase}/>)

    // Simulate enter press and assert DOM changed
    expect(queryByText(phrase)).not.toBeInTheDocument()
    fireEvent.keyDown(getByLabelText('test-div'), { key: 'Enter', code: 'Enter' })
    expect(getByText(phrase)).toBeInTheDocument()
    unmount(); // making sure there are no errors on cleanup
  });
});
