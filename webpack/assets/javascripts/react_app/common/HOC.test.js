import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import { callOnMount, withRenderHandler, callOnPopState } from './HOC';
import { rtlHelpers } from './testHelpers';

const Component = () => <div>component mounted</div>;

const baseProps = {
  isLoading: false,
  hasData: false,
  hasError: false,
  message: {
    type: 'empty',
    text: 'empty',
  },
};

describe('HOCs', () => {
  describe('withRenderHandler', () => {
    it('renders the main component when data is available', () => {
      const RenderHandler = withRenderHandler({ Component });

      render(<RenderHandler {...baseProps} hasData />);

      expect(screen.getByText('component mounted')).toBeInTheDocument();
    });

    it('renders the loading page when loading without data', () => {
      const RenderHandler = withRenderHandler({ Component });

      render(<RenderHandler {...baseProps} isLoading />);

      expect(screen.getByLabelText('Loading Page')).toBeInTheDocument();
      expect(screen.queryByText('component mounted')).not.toBeInTheDocument();
    });

    it('renders the error page when an error is present', () => {
      const RenderHandler = withRenderHandler({ Component });

      rtlHelpers.renderWithStore(<RenderHandler {...baseProps} hasError />);

      expect(screen.getByText('No Results')).toBeInTheDocument();
      expect(screen.getByText('empty')).toBeInTheDocument();
      expect(screen.queryByText('component mounted')).not.toBeInTheDocument();
    });

    it('renders the empty page when there is no data', () => {
      const RenderHandler = withRenderHandler({ Component });

      rtlHelpers.renderWithStore(<RenderHandler {...baseProps} />);

      expect(screen.getByText('No Results')).toBeInTheDocument();
      expect(screen.getByText('empty')).toBeInTheDocument();
      expect(screen.queryByText('component mounted')).not.toBeInTheDocument();
    });

    it('renders the main component instead of loading when data is available while loading', () => {
      const RenderHandler = withRenderHandler({ Component });

      render(<RenderHandler {...baseProps} isLoading hasData />);

      expect(screen.getByText('component mounted')).toBeInTheDocument();
      expect(screen.queryByLabelText('Loading Page')).not.toBeInTheDocument();
    });

    it('renders custom loading, error, and empty components when provided', () => {
      const LoadingComponent = () => <div>custom loading</div>;
      const ErrorComponent = () => <div>custom error</div>;
      const EmptyComponent = () => <div>custom empty</div>;
      const RenderHandler = withRenderHandler({
        Component,
        LoadingComponent,
        ErrorComponent,
        EmptyComponent,
      });

      const { rerender } = render(<RenderHandler {...baseProps} isLoading />);
      expect(screen.getByText('custom loading')).toBeInTheDocument();

      rerender(<RenderHandler {...baseProps} hasError />);
      expect(screen.getByText('custom error')).toBeInTheDocument();

      rerender(<RenderHandler {...baseProps} />);
      expect(screen.getByText('custom empty')).toBeInTheDocument();
    });
  });

  describe('callOnMount', () => {
    it('invokes the callback once when the wrapped component mounts', () => {
      const callback = jest.fn();
      const OnMount = callOnMount(callback)(Component);

      render(<OnMount />);

      expect(callback).toHaveBeenCalledTimes(1);
    });

    it('passes component props to the callback', () => {
      const callback = jest.fn();
      const OnMount = callOnMount(callback)(Component);
      const props = { testProp: 'test-value' };

      render(<OnMount {...props} />);

      expect(callback).toHaveBeenCalledWith(props);
    });

    it('renders the wrapped component', () => {
      const OnMount = callOnMount(jest.fn())(Component);

      render(<OnMount />);

      expect(screen.getByText('component mounted')).toBeInTheDocument();
    });
  });

  describe('callOnPopState', () => {
    const routerProps = {
      history: { action: 'PUSH' },
      location: { search: 'search' },
    };

    it('invokes the callback when navigating back and the search query changes', () => {
      const callback = jest.fn();
      const OnPopState = callOnPopState(callback)(Component);
      const { rerender } = render(<OnPopState {...routerProps} />);

      rerender(
        <OnPopState
          history={{ action: 'POP' }}
          location={{ search: 'changed' }}
        />
      );

      expect(callback).toHaveBeenCalledTimes(1);
    });

    it('does not invoke the callback on the initial mount', () => {
      const callback = jest.fn();
      const OnPopState = callOnPopState(callback)(Component);

      render(
        <OnPopState
          history={{ action: 'POP' }}
          location={{ search: 'search' }}
        />
      );

      expect(callback).not.toHaveBeenCalled();
    });

    it('does not invoke the callback when the history action is not POP', () => {
      const callback = jest.fn();
      const OnPopState = callOnPopState(callback)(Component);
      const { rerender } = render(<OnPopState {...routerProps} />);

      rerender(
        <OnPopState
          history={{ action: 'PUSH' }}
          location={{ search: 'changed' }}
        />
      );

      expect(callback).not.toHaveBeenCalled();
    });

    it('renders the wrapped component', () => {
      const OnPopState = callOnPopState(jest.fn())(Component);

      render(<OnPopState {...routerProps} />);

      expect(screen.getByText('component mounted')).toBeInTheDocument();
    });
  });
});
