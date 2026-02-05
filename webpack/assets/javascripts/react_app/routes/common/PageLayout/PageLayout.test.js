import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import { screen } from '@testing-library/react';

import PageLayout from './PageLayout';
import '@testing-library/jest-dom';
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

  it('should have Search', () => {
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

  it('should render custom breadcrumbs', () => {
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

  it('should render toolbar buttons', () => {
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

  it('should render content', () => {
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

  it('should show spinner when isLoading is true', () => {
    const { container } = renderWithStore(
      <Router>
        <PageLayout {...pageLayoutMock} isLoading={true}>
          <div>Content</div>
        </PageLayout>
      </Router>
    );
    expect(container.querySelector('#toolbar-spinner')).toBeInTheDocument();
  });

  it('should not show spinner when isLoading is false', () => {
    const { container } = renderWithStore(
      <Router>
        <PageLayout {...pageLayoutMock} isLoading={false}>
          <div>Content</div>
        </PageLayout>
      </Router>
    );
    expect(container.querySelector('#toolbar-spinner')).toBeNull();
  });
});
