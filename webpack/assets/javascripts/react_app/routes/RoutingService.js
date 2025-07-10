import { Route } from 'react-router-dom';
import React from 'react';
import { visit } from '../common/helpers';
import { addGlobalFill } from '../components/common/Fill/GlobalFill';

let currentPath = window.location.href;

/**
 * Adds a plugin's routes into core
 * @param  {String} id  plugin's id - can be its name
 * @param  {Array}   routes an array that contains a plugin's routes
 */
export const registerRoutes = (id, routes) =>
  routes.map(({ render, path, ...routeProps }, index) =>
    addGlobalFill(
      'routes',
      `${id}-${index}`,
      <Route
        path={path}
        key={path}
        {...routeProps}
        element={<RouteWrapper render={render} />}
      />
    )
  );

/**
 * Route wrapper component to mimic legacy `render` behavior
 */
const RouteWrapper = ({ render }) => {
  const location = window.location;
  const pathname = location.pathname;
  const search = location.search;

  removeRailsContent();
  updatePath(`${pathname}${search}`);

  // You may use `useLocation()` here if this becomes a component inside Router context
  return render({ location });
};

export const fallbackRoute = () => {
  const nextPath = window.location.href;
  if (currentPath !== nextPath) {
    updatePath(nextPath);
    return visit(nextPath);
  }
  return null;
};

const updatePath = newPath => {
  if (newPath) currentPath = newPath;
};

const removeRailsContent = () => {
  const railsContainer = document.getElementById('rails-app-content');
  if (railsContainer) railsContainer.remove();
  document.body.classList.add('react-page');
};
