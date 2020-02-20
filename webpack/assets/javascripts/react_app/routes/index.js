import React from 'react';
import { Switch, Route } from 'react-router-dom';
import URI from 'urijs';
import { routes } from './routes';

let currentPath = null;

const AppSwitcher = () => {
  const updateCurrentPath = () => {
    currentPath = getURIPath();
  };

  const getURIPath = () => {
    /**
      we decided to use URIjs to get the full path because 
      turbolinks interpolates the window.location and sometimes instead of the full path,
      e.g.: "/architectures/edit" we will get only "/architectures".
     */
    const uri = new URI();
    return uri.pathname();
  };

  const handleRailsContainer = () => {
    const railsContainer = document.getElementById('rails-app-content');
    if (railsContainer) railsContainer.remove();
  };

  const handleTurbolinksVisit = (location, nextPath) => {
    const { state: { useTurbolinks } = {} } = location;
    /**
      Couldn't use routeProps history because it's different than 
      the window.history and sometimes doesn't contain the turbolinks object.
    */
    const turbolinksVisitCalled = window.history.state && !window.history.state.turbolinks;
    if (useTurbolinks && turbolinksVisitCalled) {
      window.Turbolinks.visit(nextPath);
    }
  };

  const handleRoute = (Component, props) => {
    handleRailsContainer();
    updateCurrentPath();
    return <Component {...props} />;
  };

  const handleFallbackRoute = ({ location }) => {
    const nextPath = getURIPath();
    if (currentPath !== nextPath) {
      updateCurrentPath();
      handleTurbolinksVisit(location, nextPath);
    }
    return null;
  };

  return (
    <Switch>
      {routes.map(({ render: Component, path, ...routeProps }) => (
        <Route
          path={path}
          key={path}
          {...routeProps}
          render={props => handleRoute(Component, props)}
        />
      ))}
      <Route render={handleFallbackRoute} />
    </Switch>
  );
};

export default AppSwitcher;
