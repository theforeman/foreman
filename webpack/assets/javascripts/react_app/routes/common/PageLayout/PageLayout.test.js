import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import { screen, within } from '@testing-library/react';

import PageLayout from './PageLayout';
import '@testing-library/jest-dom';
import { breadcrumbBar } from '../../../components/BreadcrumbBar/BreadcrumbBar.fixtures';
import { pageLayoutMock } from './PageLayout.fixtures';
import { rtlHelpers } from '../../../common/rtlTestHelpers';

const { renderWithStore } = rtlHelpers;

jest.unmock('react-helmet');
describe('PageLayout', () => {
  it('should render header text', () => {
    const header = 'My Header';
    const { getByText } = renderWithStore(
      <Router>
        <PageLayout
          {...pageLayoutMock}
          breadcrumbOptions={null}
          header={header}
          searchable={false}
        >
          <div>Content</div>
        </PageLayout>
      </Router>
    );
    const headerElement = getByText(header);
    expect(headerElement).toBeInTheDocument();
    expect(screen.queryAllByLabelText('Search')).toHaveLength(0);
  });

  it('renders customHeader node inside title breadcrumb region', () => {
    function CompositeHeader() {
      return (
        <span data-testid="composite-header">
          Scoped <strong>Hosts</strong> view
        </span>
      );
    }

    renderWithStore(
      <Router>
        <PageLayout
          {...pageLayoutMock}
          breadcrumbOptions={null}
          customHeader={<CompositeHeader />}
          searchable={false}
        >
          <div>Content</div>
        </PageLayout>
      </Router>
    );

    const composite = screen.getByTestId('composite-header');
    expect(composite).toBeInTheDocument();
    expect(composite.closest('#page-title')).toBeInTheDocument();
    expect(
      within(composite).getByText(
        (_, element) => element?.textContent === 'Scoped Hosts view'
      )
    ).toBeInTheDocument();
  });

  it('renders SearchBar in toolbar when searchable is true', () => {
    const onSearchMock = jest.fn();
    const { getByLabelText } = renderWithStore(
        <Router>
          <PageLayout
            {...pageLayoutMock}
            searchable={true}
            onSearch={onSearchMock}
          >
            <div>Content</div>
        </PageLayout>
      </Router>
    );
    expect(getByLabelText('Search input')).toBeInTheDocument();
    expect(getByLabelText('Search')).toBeInTheDocument();
  });

  it('renders customBreadcrumbs when provided', () => {
    const customBreadcrumbs = <div>test Breadcrumbs</div>;
    const { getByText } = renderWithStore(
        <Router>
          <PageLayout
            {...pageLayoutMock}
            searchable={false}
            customBreadcrumbs={customBreadcrumbs}
          >
            <div>Content</div>
        </PageLayout>
      </Router>
    );
    const breadcrumbsElement = getByText('test Breadcrumbs');
    expect(breadcrumbsElement).toBeInTheDocument();
  });

  it('renders BreadcrumbBar from breadcrumbOptions', () => {
    renderWithStore(
      <Router>
        <PageLayout
          {...pageLayoutMock}
          searchable={false}
          breadcrumbOptions={breadcrumbBar}
          header="Page title"
        >
          <div>Content</div>
        </PageLayout>
      </Router>
    );
    expect(screen.getByText('root')).toBeInTheDocument();
  });

  it('renders beforeToolbarComponent between title and toolbar sections', () => {
    renderWithStore(
      <Router>
        <PageLayout
          {...pageLayoutMock}
          searchable={false}
          breadcrumbOptions={null}
          toolbarButtons={<button type="button">TB</button>}
          beforeToolbarComponent={
            <div data-testid="before-toolbar">Before toolbar</div>
          }
        >
          <div>Content</div>
        </PageLayout>
      </Router>
    );
    expect(screen.getByTestId('before-toolbar')).toHaveTextContent(
      'Before toolbar'
    );
    expect(screen.getByText('TB')).toBeInTheDocument();
  });

  it('renders toolbarButtons in toolbar', () => {
    const toolbarButtons = <button>test Button</button>;
    const { getByText } = renderWithStore(
        <Router>
          <PageLayout
            {...pageLayoutMock}
            searchable={false}
            toolbarButtons={toolbarButtons}
          >
            <div>Content</div>
        </PageLayout>
      </Router>
    );
    const buttonElement = getByText('test Button');
    expect(buttonElement).toBeInTheDocument();
  });

  it('renders children in main content PageSection', () => {
    const { getByText } = renderWithStore(
        <Router>
          <PageLayout {...pageLayoutMock} searchable={false}>
            <div>Content</div>
        </PageLayout>
      </Router>
    );
    const contentElement = getByText('Content');
    expect(contentElement).toBeInTheDocument();
  });

  it('shows toolbar spinner when isLoading is true', () => {
    const { container } = renderWithStore(
      <Router>
        <PageLayout {...pageLayoutMock} isLoading={true}>
          <div>Content</div>
        </PageLayout>
      </Router>
    );
    expect(container.querySelector('#toolbar-spinner')).toBeInTheDocument();
  });

  it('does not render toolbar spinner when isLoading is false', () => {
    const { container } = renderWithStore(
      <Router>
        <PageLayout {...pageLayoutMock} isLoading={false}>
          <div>Content</div>
        </PageLayout>
      </Router>
    );
    expect(container.querySelector('#toolbar-spinner')).toBeNull();
  });

  it('renders customToolbar instead of built-in toolbar (skips SearchBar)', () => {
    renderWithStore(
      <Router>
        <PageLayout
          {...pageLayoutMock}
          searchable={false}
          breadcrumbOptions={null}
          customToolbar={<div data-testid="custom-toolbar-slot">Custom</div>}
          header="Index"
        >
          <div>Content</div>
        </PageLayout>
      </Router>
    );
    expect(screen.getByTestId('custom-toolbar-slot')).toHaveTextContent(
      'Custom'
    );
    expect(screen.queryByLabelText('Search input')).not.toBeInTheDocument();
  });
});
