import React from 'react';
import { renderRoute, registerRoutes } from '../RoutingService';
import { routes } from './Routes.fixtures';
import store from '../../redux';

jest.unmock('../../redux');
jest.unmock('../RoutingService');

const props = { location: { pathname: '/test' } };
const renderFn = () => <div> Test </div>;

describe('Routing Service', () => {
  it('rendering a route', () => {
    expect(renderRoute(renderFn, props)).toMatchSnapshot();
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
