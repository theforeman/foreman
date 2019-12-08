import React, { useEffect } from 'react';
import { Switch, Route, matchPath } from 'react-router-dom';
import PropTypes from 'prop-types';
import URI from 'urijs';
import { routes } from '../routes';

let currentPath = null;

const AppSwitcher = ({ location }) => {
  useEffect(() => {
    const nextPath = getURIPath();
    if (currentPath !== nextPath) {
      updateCurrentPath();
      if (!isRegisteredRoute(nextPath)) {
        handleTurbolinksVisit(location, nextPath);
      }
    }
  }, [location]);

  const isRegisteredRoute = nextPath =>
    routes.includes(({ path }) => matchPath(nextPath, path));

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

  const handleTurbolinksVisit = (
    { state: { useTurbolinks } = {} },
    nextPath
  ) => {
    /**
      Couldn't use routeProps history because it's different than 
      the window.history and sometimes doesn't contain the turbolinks object.
    */
    const turbolinksVisitCalled = !window.history.state.turbolinks;
    if (useTurbolinks && turbolinksVisitCalled) {
      window.Turbolinks.visit(nextPath);
    }
  };

  const handleRoute = (Component, props) => {
    handleRailsContainer();
    updateCurrentPath();
    return <Component {...props} />;
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
    </Switch>
  );
};

AppSwitcher.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string,
    search: PropTypes.string,
    hash: PropTypes.string,
    query: PropTypes.object,
  }),
};

AppSwitcher.defaultProps = {
  location: {},
};

export default AppSwitcher;
