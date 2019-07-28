import React from 'react';
import { renderRoute, registerRoutes } from '../RoutingService';
import { routes } from './Routes.fixtures';
import store from '../../redux';

jest.unmock('../../redux');
jest.unmock('../RoutingService');

const props = { location: { pathname: '/test' } };
const renderFn = () => <div> Test </div>;
const callback = location => location.pathname === '/test';
const falseCallback = () => false;

describe('Routing Service', () => {
  it('rendering a route without a callback', () => {
    expect(renderRoute(renderFn, props)).toMatchSnapshot();
  });
  it('rendering a route with a callback', () => {
    expect(renderRoute(renderFn, props, callback)).toMatchSnapshot();
  });
  it('rendering a route with a falsy callback', () => {
    expect(renderRoute(renderFn, props, falseCallback)).toMatchSnapshot();
  });
});

describe('PluginRoutes', () => {
  describe('rendering', () => {
    it('Adding global routes', () => {
      registerRoutes('some-id', routes);
      expect(store.getState().extendable).toMatchSnapshot();
    });
  });
});
