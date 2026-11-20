import React from 'react';
import { Provider } from 'react-redux';
import configureMockStore from 'redux-mock-store';
import { BrowserRouter as Router } from 'react-router-dom';
import { fireEvent, screen, render, act } from '@testing-library/react';
import "@testing-library/jest-dom/extend-expect"; // for toBeVisable
import Layout from '../index';
import { layoutData, fullLayoutStore } from '../Layout.fixtures';
import { initMockStore } from '../../../common/testHelpers';
import { reducers } from '../index';

const mockStore = configureMockStore(reducers);
const store = mockStore({ ...initMockStore, ...fullLayoutStore });

jest.useFakeTimers();
describe('Layout', () => {
  it('Layout', async () => {
    render(
      <Provider store={store}>
        <Router>
          <Layout data={layoutData} />
        </Router>
      </Provider>
    );
    expect(screen.getByText('Monitor')).toBeVisible();
    expect(screen.getByText('Dashboard')).toBeVisible();
    expect(screen.getByText('All Hosts')).not.toBeVisible();
    await act(async () => {
      await fireEvent.click(screen.getByText('Hosts'));
    });
    expect(screen.getByText('Monitor')).toBeVisible();
    expect(screen.getByText('Dashboard')).not.toBeVisible();
    expect(screen.getByText('All Hosts')).toBeVisible();
    expect(screen.getByText('Production')).toBeVisible();
  });

  it('renders the nav toggle icon without the PF Icon wrapper', () => {
    // PF6 Icon sets its own color and size, so a wrapped icon ignores the
    // masthead's white toggle color
    const { container } = render(
      <Provider store={store}>
        <Router>
          <Layout data={layoutData} />
        </Router>
      </Provider>
    );
    const toggle = container.querySelector('[data-ouia-component-id="nav-toggle"]');
    expect(toggle.querySelector('svg')).toBeInTheDocument();
    expect(toggle.querySelector('.pf-v6-c-icon')).toBeNull();
  });

  it('expands the open sidebar below the PF6 xl breakpoint', () => {
    // PF6 hides the sidebar below 75rem unless it has pf-m-expanded, which it
    // only gets when Page tracks mobile view (jsdom's 1024px window is mobile)
    const { container } = render(
      <Provider store={store}>
        <Router>
          <Layout data={layoutData} />
        </Router>
      </Provider>
    );
    expect(container.querySelector('.pf-v6-c-page__sidebar')).toHaveClass(
      'pf-m-expanded'
    );
  });
});
