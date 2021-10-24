import { Route } from 'react-router-dom';
import React from 'react';
import { visit } from '../../foreman_navigation';
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
        render={renderProps => renderRoute(render, renderProps)}
      />
    )
  );

/**
 * a Helper function for rendering a route
 * @param {Function} renderFn - a component's rendering function
 * @param {Object} props - routing props
 */
export const renderRoute = (renderFn, props) => {
  const {
    location,
    location: { pathname, search },
  } = props;
  console.log('here');
  removeRailsContent();
  location && updatePath(`${pathname}${search}`);
  return renderFn(props);
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
  console.log(document.getElementById('rails-app-content'));
  const railsContainer = document.getElementById('rails-app-content');
  if (railsContainer) railsContainer.remove();
};
