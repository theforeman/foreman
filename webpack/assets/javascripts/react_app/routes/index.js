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
    return null;
  };

  return (
    <React.Fragment>
      <Switch>
        {routes.map(({ render: Component, path, ...routeProps }) => (
          <Route
            path={path}
            key={path}
            {...routeProps}
            render={componentProps => handleRoute(Component, componentProps)}
          />
        ))}
        <Route render={handleFallbackRoute} />
      </Switch>
      {props.children}
    </React.Fragment>
  );
};

AppSwitcher.propTypes = {
  children: PropTypes.object,
};

AppSwitcher.defaultProps = {
  children: null,
};

export default AppSwitcher;
