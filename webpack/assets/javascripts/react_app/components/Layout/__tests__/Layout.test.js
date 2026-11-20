import React from 'react';
import { Provider } from 'react-redux';
import configureMockStore from 'redux-mock-store';
import { BrowserRouter as Router } from 'react-router-dom';
import {
  fireEvent,
  screen,
  render,
  act,
  cleanup,
} from '@testing-library/react';
import "@testing-library/jest-dom/extend-expect"; // for toBeVisable
import Layout from '../index';
import history from '../../../history';
import { layoutData, fullLayoutStore } from '../Layout.fixtures';
import { initMockStore } from '../../../common/testHelpers';
import { reducers } from '../index';

const mockStore = configureMockStore(reducers);
const store = mockStore({ ...initMockStore, ...fullLayoutStore });

jest.useFakeTimers();
describe('Layout', () => {
  afterEach(() => {
    cleanup();
    history.push('/');
  });

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

  it('highlights All Hosts for a nested host URL', async () => {
    render(
      <Provider store={store}>
        <Router>
          <Layout data={layoutData} />
        </Router>
      </Provider>
    );

    await act(async () => {
      history.push('/hosts/test-host.example.com');
    });
    await act(async () => {
      fireEvent.click(screen.getByText('Hosts'));
    });

    expect(screen.getByRole('link', { name: 'All Hosts' })).toHaveAttribute(
      'aria-current',
      'page'
    );
    expect(
      screen.getByRole('link', { name: 'Create Host' })
    ).not.toHaveAttribute('aria-current', 'page');
  });
});
