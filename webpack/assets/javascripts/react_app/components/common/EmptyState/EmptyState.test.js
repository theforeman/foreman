import React from 'react';
import { screen, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import { push } from 'connected-react-router';
import DefaultEmptyState, { EmptyStatePattern } from './index';
import { rtlHelpers } from '../../../common/testHelpers';
import { props, action } from './EmptyStateFixtures';

jest.mock('connected-react-router', () => ({
  ...jest.requireActual('connected-react-router'),
  push: jest.fn(() => ({ type: 'DUMMY' })),
}));

describe('Default Empty State', () => {
  beforeEach(() => {
    push.mockClear();
  });
  afterAll(() => {
    jest.unmock('connected-react-router');
  });

  it('should render documentation when given a url', () => {
    rtlHelpers.renderWithStore(
      <DefaultEmptyState {...props} action={action} />
    );

    // Test basic content rendering
    expect(screen.getByText('Printers')).toBeInTheDocument();
    expect(
      screen.getByText('Printers print a file from the computer')
    ).toBeInTheDocument();
    expect(
      screen.getByText('For more information please see')
    ).toBeInTheDocument();

    const docLink = screen.getByRole('link', { name: 'documentation' });
    expect(docLink).toBeInTheDocument();
    expect(docLink).toHaveAttribute('href', 'https://example.com');
    expect(docLink).toHaveAttribute('target', '_blank');
    expect(docLink).toHaveAttribute('rel', 'external noreferrer noopener');

    // Test action button - PatternFly Button renders as <a> with button classes
    const actionButton = screen.getByText('action-title');
    expect(actionButton).toBeInTheDocument();
    expect(actionButton).toHaveAttribute(
      'data-ouia-component-id',
      'empty-state-action-button'
    );
    expect(actionButton).toHaveClass('pf-v5-c-button', 'pf-m-primary');
  });

  it('should render secondary actions', () => {
    rtlHelpers.renderWithStore(
      <DefaultEmptyState
        {...props}
        action={action}
        secondaryActions={[action]}
      />
    );

    // Test primary action
    const primaryButton = document.querySelector(
      '[data-ouia-component-id="empty-state-action-button"]'
    );
    expect(primaryButton).toBeInTheDocument();
    expect(primaryButton).toHaveClass('pf-v5-c-button', 'pf-m-primary');
    expect(primaryButton).toHaveTextContent('action-title');

    // Test secondary action
    const secondaryButton = document.querySelector(
      '[data-ouia-component-id="empty-state-secondary-action-button"]'
    );
    expect(secondaryButton).toBeInTheDocument();
    expect(secondaryButton).toHaveClass('pf-v5-c-button', 'pf-m-secondary');
    expect(secondaryButton).toHaveTextContent('action-title');
  });

  it('should dispatch navigation action when primary button is clicked', () => {
    rtlHelpers.renderWithStore(
      <DefaultEmptyState {...props} action={action} />
    );

    const actionButton = screen.getByText('action-title');
    fireEvent.click(actionButton);
    expect(push).toHaveBeenCalledWith('action-url');
  });

  it('should call custom onClick when provided instead of navigation', () => {
    const mockOnClick = jest.fn();
    const customAction = { title: 'Custom Action', onClick: mockOnClick };

    rtlHelpers.renderWithStore(
      <DefaultEmptyState {...props} action={customAction} />
    );

    const actionButton = screen.getByText('Custom Action');
    fireEvent.click(actionButton);

    expect(mockOnClick).toHaveBeenCalledTimes(1);
    expect(push).not.toHaveBeenCalled();
  });

  it('should handle secondary action clicks', () => {
    const mockSecondaryClick = jest.fn();
    const secondaryAction = {
      title: 'Secondary Action',
      onClick: mockSecondaryClick,
    };

    rtlHelpers.renderWithStore(
      <DefaultEmptyState
        {...props}
        action={action}
        secondaryActions={[secondaryAction]}
      />
    );

    const secondaryButton = screen.getByText('Secondary Action');
    fireEvent.click(secondaryButton);

    expect(mockSecondaryClick).toHaveBeenCalledTimes(1);
  });

  it('should not render action button when no action provided', () => {
    rtlHelpers.renderWithStore(<DefaultEmptyState {...props} />);

    expect(screen.getByText('Printers')).toBeInTheDocument();
    expect(
      screen.getByText('Printers print a file from the computer')
    ).toBeInTheDocument();

    // Should not have any action buttons
    expect(
      document.querySelector(
        '[data-ouia-component-id="empty-state-action-button"]'
      )
    ).not.toBeInTheDocument();
    expect(
      document.querySelector(
        '[data-ouia-component-id="empty-state-secondary-action-button"]'
      )
    ).not.toBeInTheDocument();
  });

  it('should use default props when not provided', () => {
    rtlHelpers.renderWithStore(
      <DefaultEmptyState header="Test Header" description="Test Description" />
    );

    expect(screen.getByText('Test Header')).toBeInTheDocument();
    expect(screen.getByText('Test Description')).toBeInTheDocument();

    // Should not render documentation when not provided
    expect(
      screen.queryByText('For more information please see')
    ).not.toBeInTheDocument();
  });

  it('should render with icon and proper accessibility', () => {
    rtlHelpers.renderWithStore(<DefaultEmptyState {...props} />);

    // Check heading structure
    expect(
      screen.getByRole('heading', { name: 'Printers', level: 5 })
    ).toBeInTheDocument();

    // Check icon presence (pficon class)
    const iconElement = document.querySelector('.pficon-printer');
    expect(iconElement).toBeInTheDocument();
    expect(iconElement).toHaveAttribute('aria-hidden', 'true');
  });
});

describe('Empty State Pattern', () => {
  it('should render with props', () => {
    rtlHelpers.renderWithStore(<EmptyStatePattern {...props} />);

    expect(screen.getByText('Printers')).toBeInTheDocument();
    expect(
      screen.getByText('Printers print a file from the computer')
    ).toBeInTheDocument();
    expect(
      screen.getByText('For more information please see')
    ).toBeInTheDocument();
    expect(
      screen.getByRole('link', { name: 'documentation' })
    ).toBeInTheDocument();
  });

  it('should render custom documentation element', () => {
    const customDoc = (
      <div data-testid="custom-doc">Custom Documentation Block</div>
    );

    rtlHelpers.renderWithStore(
      <EmptyStatePattern {...props} documentation={customDoc} />
    );

    expect(screen.getByTestId('custom-doc')).toBeInTheDocument();
    expect(screen.getByText('Custom Documentation Block')).toBeInTheDocument();
  });

  it('should not render documentation when not provided', () => {
    const propsWithoutDocs = { ...props };
    delete propsWithoutDocs.documentation;

    rtlHelpers.renderWithStore(<EmptyStatePattern {...propsWithoutDocs} />);

    expect(screen.getByText('Printers')).toBeInTheDocument();
    expect(
      screen.queryByText('For more information please see')
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole('link', { name: 'documentation' })
    ).not.toBeInTheDocument();
  });

  it('should render custom icon element', () => {
    const customIcon = <div data-testid="custom-icon">Custom Icon</div>;

    rtlHelpers.renderWithStore(
      <EmptyStatePattern {...props} icon={customIcon} />
    );

    expect(screen.getByTestId('custom-icon')).toBeInTheDocument();
    expect(screen.getByText('Custom Icon')).toBeInTheDocument();
  });

  it('should render action and secondary actions when provided', () => {
    const actionElement = (
      <button data-testid="primary-action">Primary Action</button>
    );
    const secondaryElement = (
      <button data-testid="secondary-action">Secondary Action</button>
    );

    rtlHelpers.renderWithStore(
      <EmptyStatePattern
        {...props}
        action={actionElement}
        secondaryActions={secondaryElement}
      />
    );

    expect(screen.getByTestId('primary-action')).toBeInTheDocument();
    expect(screen.getByTestId('secondary-action')).toBeInTheDocument();
  });

  it('should handle default documentation props', () => {
    const customDocumentation = {
      label: 'Check out our ',
      buttonLabel: 'help guide',
      url: 'https://help.example.com',
    };

    rtlHelpers.renderWithStore(
      <EmptyStatePattern {...props} documentation={customDocumentation} />
    );

    expect(screen.getByText('Check out our')).toBeInTheDocument();
    const helpLink = screen.getByRole('link', { name: 'help guide' });
    expect(helpLink).toBeInTheDocument();
    expect(helpLink).toHaveAttribute('href', 'https://help.example.com');
  });
});
