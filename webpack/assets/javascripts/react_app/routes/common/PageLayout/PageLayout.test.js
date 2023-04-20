import React from 'react';
import { Provider } from 'react-redux';
import configureMockStore from 'redux-mock-store';
import { BrowserRouter as Router } from 'react-router-dom';
import { render, screen } from '@testing-library/react';

import thunk from 'redux-thunk';
import PageLayout from './PageLayout';
import '@testing-library/jest-dom';
import { pageLayoutMock } from './PageLayout.fixtures';
import { initMockStore } from '../../../common/testHelpers';

const mockStore = configureMockStore([thunk]);

const store = mockStore({ ...initMockStore });

jest.unmock('react-helmet');
describe('PageLayout', () => {
  it('should render header text', () => {
    const header = 'My Header';
    const { getByText } = render(
      <Provider store={store}>
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
      </Provider>
    );
    const headerElement = getByText(header);
    expect(headerElement).toBeInTheDocument();
    expect(screen.queryAllByLabelText('Search')).toHaveLength(0);
  });

  it('should have Search', () => {
    const onSearchMock = jest.fn();
    const { getByLabelText } = render(
      <Provider store={store}>
        <Router>
          <PageLayout
            {...pageLayoutMock}
            searchable={true}
            onSearch={onSearchMock}
          >
            <div>Content</div>
          </PageLayout>
        </Router>
      </Provider>
    );
    expect(getByLabelText('Search input')).toBeInTheDocument();
    expect(getByLabelText('Search')).toBeInTheDocument();
  });

  it('should render custom breadcrumbs', () => {
    const customBreadcrumbs = <div>test Breadcrumbs</div>;
    const { getByText } = render(
      <Provider store={store}>
        <Router>
          <PageLayout
            {...pageLayoutMock}
            searchable={false}
            customBreadcrumbs={customBreadcrumbs}
          >
            <div>Content</div>
          </PageLayout>
        </Router>
      </Provider>
    );
    const breadcrumbsElement = getByText('test Breadcrumbs');
    expect(breadcrumbsElement).toBeInTheDocument();
  });

  it('should render toolbar buttons', () => {
    const toolbarButtons = <button>test Button</button>;
    const { getByText } = render(
      <Provider store={store}>
        <Router>
          <PageLayout
            {...pageLayoutMock}
            searchable={false}
            toolbarButtons={toolbarButtons}
          >
            <div>Content</div>
          </PageLayout>
        </Router>
      </Provider>
    );
    const buttonElement = getByText('test Button');
    expect(buttonElement).toBeInTheDocument();
  });

  it('should render content', () => {
    const { getByText } = render(
      <Provider store={store}>
        <Router>
          <PageLayout {...pageLayoutMock} searchable={false}>
            <div>Content</div>
          </PageLayout>
        </Router>
      </Provider>
    );
    const contentElement = getByText('Content');
    expect(contentElement).toBeInTheDocument();
  });
});
