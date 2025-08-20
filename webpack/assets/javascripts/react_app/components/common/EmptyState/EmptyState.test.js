import React from 'react';
import { screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import DefaultEmptyState, { EmptyStatePattern } from './index';
import { rtlHelpers, initMockStore } from '../../../common/testHelpers';
import { props, action } from './EmptyStateFixtures';

describe('Default Empty State', () => {
  const mockStore = {
    ...initMockStore,
  };

  it('should render documentation when given a url', () => {
    const { store } = rtlHelpers.renderWithStore(
      <DefaultEmptyState
        {...props}
        action={action}
      />,
      mockStore
    );

    // Test basic content rendering
    expect(screen.getByText('Printers')).toBeInTheDocument();
    expect(screen.getByText('Printers print a file from the computer')).toBeInTheDocument();
    expect(screen.getByText('For more information please see')).toBeInTheDocument();

    const docLink = screen.getByRole('link', { name: 'documentation' });
    expect(docLink).toBeInTheDocument();
    expect(docLink).toHaveAttribute('href', 'https://example.com');
    expect(docLink).toHaveAttribute('target', '_blank');
    expect(docLink).toHaveAttribute('rel', 'external noreferrer noopener');

    // Test action button - PatternFly Button renders as <a> with button classes
    const actionButton = screen.getByText('action-title');
    expect(actionButton).toBeInTheDocument();
    expect(actionButton).toHaveAttribute('data-ouia-component-id', 'empty-state-action-button');
    expect(actionButton).toHaveClass('pf-v5-c-button', 'pf-m-primary');
  });

  it('should render secondary actions', () => {
    const { store } = rtlHelpers.renderWithStore(
      <DefaultEmptyState
        {...props}
        action={action}
        secondaryActions={[action]}
      />,
      mockStore
    );

    // Test primary action
    const primaryButton = document.querySelector('[data-ouia-component-id="empty-state-action-button"]');
    expect(primaryButton).toBeInTheDocument();
    expect(primaryButton).toHaveClass('pf-v5-c-button', 'pf-m-primary');
    expect(primaryButton).toHaveTextContent('action-title');

    // Test secondary action
    const secondaryButton = document.querySelector('[data-ouia-component-id="empty-state-secondary-action-button"]');
    expect(secondaryButton).toBeInTheDocument();
    expect(secondaryButton).toHaveClass('pf-v5-c-button', 'pf-m-secondary');
    expect(secondaryButton).toHaveTextContent('action-title');
  });

  it('should dispatch navigation action when primary button is clicked', () => {
    const { store } = rtlHelpers.renderWithStore(
      <DefaultEmptyState
        {...props}
        action={action}
      />,
      mockStore
    );

    const actionButton = screen.getByText('action-title');
    fireEvent.click(actionButton);

    // Check that the store received the push action
    const actions = store.getActions();
    expect(actions).toHaveLength(1);
    expect(actions[0]).toEqual({
      type: '@@router/CALL_HISTORY_METHOD',
      payload: {
        method: 'push',
        args: ['action-url']
      }
    });
  });

  it('should call custom onClick when provided instead of navigation', () => {
    const mockOnClick = jest.fn();
    const customAction = { title: 'Custom Action', onClick: mockOnClick };

    const { store } = rtlHelpers.renderWithStore(
      <DefaultEmptyState
        {...props}
        action={customAction}
      />,
      mockStore
    );

    const actionButton = screen.getByText('Custom Action');
    fireEvent.click(actionButton);

    expect(mockOnClick).toHaveBeenCalledTimes(1);
    // Should not dispatch navigation action when onClick is provided
    expect(store.getActions()).toHaveLength(0);
  });

  it('should handle secondary action clicks', () => {
    const mockSecondaryClick = jest.fn();
    const secondaryAction = { title: 'Secondary Action', onClick: mockSecondaryClick };

    const { store } = rtlHelpers.renderWithStore(
      <DefaultEmptyState
        {...props}
        action={action}
        secondaryActions={[secondaryAction]}
      />,
      mockStore
    );

    const secondaryButton = screen.getByText('Secondary Action');
    fireEvent.click(secondaryButton);

    expect(mockSecondaryClick).toHaveBeenCalledTimes(1);
  });

  it('should not render action button when no action provided', () => {
    const { store } = rtlHelpers.renderWithStore(
      <DefaultEmptyState {...props} />,
      mockStore
    );

    expect(screen.getByText('Printers')).toBeInTheDocument();
    expect(screen.getByText('Printers print a file from the computer')).toBeInTheDocument();

    // Should not have any action buttons
    expect(document.querySelector('[data-ouia-component-id="empty-state-action-button"]')).not.toBeInTheDocument();
    expect(document.querySelector('[data-ouia-component-id="empty-state-secondary-action-button"]')).not.toBeInTheDocument();
  });

  it('should use default props when not provided', () => {
    const { store } = rtlHelpers.renderWithStore(
      <DefaultEmptyState
        header="Test Header"
        description="Test Description"
      />,
      mockStore
    );

    expect(screen.getByText('Test Header')).toBeInTheDocument();
    expect(screen.getByText('Test Description')).toBeInTheDocument();

    // Should not render documentation when not provided
    expect(screen.queryByText('For more information please see')).not.toBeInTheDocument();
  });

  it('should render with icon and proper accessibility', () => {
    const { store } = rtlHelpers.renderWithStore(
      <DefaultEmptyState {...props} />,
      mockStore
    );

    // Check heading structure
    expect(screen.getByRole('heading', { name: 'Printers', level: 5 })).toBeInTheDocument();

    // Check icon presence (pficon class)
    const iconElement = document.querySelector('.pficon-printer');
    expect(iconElement).toBeInTheDocument();
    expect(iconElement).toHaveAttribute('aria-hidden', 'true');
  });
});

describe('Empty State Pattern', () => {
  it('should render with props', () => {
    rtlHelpers.renderWithStore(<EmptyStatePattern {...props} />, initMockStore);

    expect(screen.getByText('Printers')).toBeInTheDocument();
    expect(screen.getByText('Printers print a file from the computer')).toBeInTheDocument();
    expect(screen.getByText('For more information please see')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'documentation' })).toBeInTheDocument();
  });

  it('should render custom documentation element', () => {
    const customDoc = <div data-testid="custom-doc">Custom Documentation Block</div>;

    rtlHelpers.renderWithStore(
      <EmptyStatePattern
        {...props}
        documentation={customDoc}
      />,
      initMockStore
    );

    expect(screen.getByTestId('custom-doc')).toBeInTheDocument();
    expect(screen.getByText('Custom Documentation Block')).toBeInTheDocument();
  });

  it('should not render documentation when not provided', () => {
    const propsWithoutDocs = { ...props };
    delete propsWithoutDocs.documentation;

    rtlHelpers.renderWithStore(<EmptyStatePattern {...propsWithoutDocs} />, initMockStore);

    expect(screen.getByText('Printers')).toBeInTheDocument();
    expect(screen.queryByText('For more information please see')).not.toBeInTheDocument();
    expect(screen.queryByRole('link', { name: 'documentation' })).not.toBeInTheDocument();
  });

  it('should render custom icon element', () => {
    const customIcon = <div data-testid="custom-icon">Custom Icon</div>;

    rtlHelpers.renderWithStore(
      <EmptyStatePattern
        {...props}
        icon={customIcon}
      />,
      initMockStore
    );

    expect(screen.getByTestId('custom-icon')).toBeInTheDocument();
    expect(screen.getByText('Custom Icon')).toBeInTheDocument();
  });

  it('should render action and secondary actions when provided', () => {
    const actionElement = <button data-testid="primary-action">Primary Action</button>;
    const secondaryElement = <button data-testid="secondary-action">Secondary Action</button>;

    rtlHelpers.renderWithStore(
      <EmptyStatePattern
        {...props}
        action={actionElement}
        secondaryActions={secondaryElement}
      />,
      initMockStore
    );

    expect(screen.getByTestId('primary-action')).toBeInTheDocument();
    expect(screen.getByTestId('secondary-action')).toBeInTheDocument();
  });

  it('should handle default documentation props', () => {
    const customDocumentation = {
      label: 'Check out our ',
      buttonLabel: 'help guide',
      url: 'https://help.example.com'
    };

    rtlHelpers.renderWithStore(
      <EmptyStatePattern
        {...props}
        documentation={customDocumentation}
      />,
      initMockStore
    );

    expect(screen.getByText('Check out our')).toBeInTheDocument();
    const helpLink = screen.getByRole('link', { name: 'help guide' });
    expect(helpLink).toBeInTheDocument();
    expect(helpLink).toHaveAttribute('href', 'https://help.example.com');
  });
});
