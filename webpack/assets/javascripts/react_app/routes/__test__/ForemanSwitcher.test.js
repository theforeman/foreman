import React from 'react';
import { Route } from 'react-router-dom';
import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import ForemanSwitcher from '../ForemanSwitcher/ForemanSwitcher';

const routes = {
  routes: [<Route key="1" path="/path1" />, <Route key="2" path="path2" />],
};

const fixtures = {
  'renders ForemanSwitcher with routes': routes,
};
describe('ForemanSwitcher', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(ForemanSwitcher, fixtures);
  });
});
