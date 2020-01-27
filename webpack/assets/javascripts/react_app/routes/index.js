import React from 'react';
import { Switch, Route } from 'react-router-dom';
import { routes } from './routes';
import Legacy from '../components/Legacy';

const AppSwitcher = () => {
  const handleRailsContainer = () => {
    const railsContainer = document.getElementById('rails-app-content');
    if (railsContainer) railsContainer.remove();
  };

  const handleReactRoute = (Component, props) => {
    handleRailsContainer();
    return <Component {...props} />;
  };

  return (
    <Switch>
      {routes.map(({ render: Component, path, ...routeProps }) => (
        <Route
          path={path}
          key={path}
          {...routeProps}
          render={props => handleReactRoute(Component, props)}
        />
      ))}
      <Route render={props => <Legacy {...props} />} />
    </Switch>
  );
};

export default AppSwitcher;
