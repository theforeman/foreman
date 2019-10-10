import React from 'react';
import { Switch, Route } from 'react-router-dom';
import PropTypes from 'prop-types';
import { routes } from './routes';
import { visit } from '../../foreman_navigation';

let currentPath = window.location.href;

const AppSwitcher = props => {
  const updateCurrentPath = nextPath => {
    currentPath = nextPath;
  };

  const handleRailsContainer = () => {
    const railsContainer = document.getElementById('rails-app-content');
    if (railsContainer) railsContainer.remove();
  };

  const handleRoute = (Component, componentProps) => {
    handleRailsContainer();
    updateCurrentPath();
    return <Component {...componentProps} />;
  };

  const handleFallbackRoute = () => {
    const nextPath = window.location.href;
    if (currentPath !== nextPath) {
      updateCurrentPath(nextPath);
      visit(nextPath);
    }
    return props.children;
  };

  const { children, ...rest } = props;

  return (
    <Switch>
      {routes.map(({ render: Component, path, ...routeProps }) => (
        <Route
          path={path}
          key={path}
          {...routeProps}
          render={componentProps =>
            handleRoute(Component, { ...componentProps, ...rest })
          }
        />
      ))}
      <Route render={handleFallbackRoute} />
    </Switch>
  );
};

AppSwitcher.propTypes = {
  children: PropTypes.object,
};

AppSwitcher.defaultProps = {
  children: undefined,
};

export default AppSwitcher;
