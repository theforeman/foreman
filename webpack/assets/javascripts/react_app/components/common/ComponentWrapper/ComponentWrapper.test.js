import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import componentRegistry from '../../componentRegistry';
import ComponentWrapper from './ComponentWrapper';

jest.mock('@apollo/client/link/batch-http');
jest.mock('../../componentRegistry');

const AwesomeComponent = ({ label = 'Awesome Component' }) => (
  <div>{label}</div>
);

describe('ComponentWrapper', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders a registered component from the component registry', () => {
    componentRegistry.getComponent = jest.fn(() => ({
      type: AwesomeComponent,
    }));

    render(<ComponentWrapper data={{ component: 'AwesomeComponent' }} />);

    expect(screen.getByText('Awesome Component')).toBeInTheDocument();
    expect(componentRegistry.getComponent).toHaveBeenCalledWith(
      'AwesomeComponent'
    );
  });

  it('passes componentProps to the registered component', () => {
    componentRegistry.getComponent = jest.fn(() => ({
      type: AwesomeComponent,
    }));

    render(
      <ComponentWrapper
        data={{
          component: 'AwesomeComponent',
          componentProps: { label: 'Custom label from props' },
        }}
      />
    );

    expect(screen.getByText('Custom label from props')).toBeInTheDocument();
  });

  it('throws when the component name is not registered in the registry', () => {
    componentRegistry.getComponent = jest.fn(() => undefined);

    // eslint-disable-next-line no-console
    const originalConsoleError = console.error;
    // eslint-disable-next-line no-console
    console.error = jest.fn();

    expect(() => {
      render(
        <ComponentWrapper data={{ component: 'NotAwesomeComponent' }} />
      );
    }).toThrow('Component name is missing!');

    // eslint-disable-next-line no-console
    console.error = originalConsoleError;
  });

  it('throws when attempting to wrap ComponentWrapper with itself', () => {
    componentRegistry.getComponent = jest.fn(() => ({
      type: AwesomeComponent,
    }));

    // eslint-disable-next-line no-console
    const originalConsoleError = console.error;
    // eslint-disable-next-line no-console
    console.error = jest.fn();

    expect(() => {
      render(<ComponentWrapper data={{ component: 'ComponentWrapper' }} />);
    }).toThrow('Cannot wrap component wrapper');

    expect(componentRegistry.getComponent).not.toHaveBeenCalled();

    // eslint-disable-next-line no-console
    console.error = originalConsoleError;
  });
});
