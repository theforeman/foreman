import React from 'react';
import useSubmitOnEnter from './useSubmitOnEnter';
import { render } from '@testing-library/react'

// It's hard to test this hook in isolation since what it returns is not the important part,
// rather that it attaches and removes an event listener properly. Testing within a component
// for this reason.
const TestComponent = ({ testRef, onSubmit }) => {
  useSubmitOnEnter(testRef, onSubmit)
  return (<>{'testing'}</>);
}

describe('useSubmitOnEnter', () => {
  it('should attach event listener on mount, use callback, and remove on unmount', () => {
    const events = {}; // Mocking out DOM event listeners
    const addEventListener = (event, handle) => events[event] = handle;
    const removeEventListener = event => events[event] = undefined;
    const onSubmit = jest.fn();
    const testRef = {
      current: {
        addEventListener, removeEventListener
      },
    };

    const { unmount } = render(<TestComponent testRef={testRef} onSubmit={onSubmit} />)

    expect(onSubmit.mock.calls).toHaveLength(0); // Should not have been called yet
    events['keydown']({ code: 'NotEnter' }); // Simulate random key press
    expect(onSubmit.mock.calls).toHaveLength(0); // Hook has not run callback because it's not enter
    events['keydown']({ code: 'Enter' }); // Simulate enter key
    expect(onSubmit.mock.calls).toHaveLength(1); // Hook has run callback
    unmount();
    expect(events['keydown']).toBeUndefined; // Event listener has been removed on unmount
  });
});
