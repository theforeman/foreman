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

  describe('sidebar managed by PF6 Page', () => {
    // PF6 Page reads its own width; jsdom reports 0 for clientWidth
    const DESKTOP_WIDTH = 1400;
    const MOBILE_WIDTH = 1100;
    const PAGE_RESIZE_DEBOUNCE = 250;
    let pageWidth;
    let clientWidthSpy;

    const resizeTo = width => {
      pageWidth = width;
      act(() => {
        window.dispatchEvent(new Event('resize'));
        jest.advanceTimersByTime(PAGE_RESIZE_DEBOUNCE);
      });
    };
    const renderLayout = () => {
      const { container } = render(
        <Provider store={store}>
          <Router>
            <Layout data={layoutData} />
          </Router>
        </Provider>
      );
      return {
        sidebar: () => container.querySelector('.pf-v6-c-page__sidebar'),
      };
    };

    beforeEach(() => {
      pageWidth = DESKTOP_WIDTH;
      clientWidthSpy = jest
        .spyOn(HTMLElement.prototype, 'clientWidth', 'get')
        .mockImplementation(() => pageWidth);
    });
    afterEach(() => {
      clientWidthSpy.mockRestore();
    });

    it('closes the sidebar below 75rem and opens it again above', () => {
      const { sidebar } = renderLayout();
      expect(sidebar()).not.toHaveClass('pf-m-collapsed');

      resizeTo(MOBILE_WIDTH);
      expect(sidebar()).toHaveClass('pf-m-collapsed');

      resizeTo(DESKTOP_WIDTH);
      expect(sidebar()).not.toHaveClass('pf-m-collapsed');
    });

    it('opens the sidebar as an overlay from the toggle in mobile view', () => {
      pageWidth = MOBILE_WIDTH;
      const { sidebar } = renderLayout();
      expect(sidebar()).toHaveClass('pf-m-collapsed');
      fireEvent.click(screen.getByRole('button', { name: 'Side navigation toggle' }));
      expect(sidebar()).toHaveClass('pf-m-expanded');
    });

    it('collapses the sidebar from the toggle on desktop', () => {
      const { sidebar } = renderLayout();
      fireEvent.click(screen.getByRole('button', { name: 'Side navigation toggle' }));
      expect(sidebar()).toHaveClass('pf-m-collapsed');
    });
  });
});
