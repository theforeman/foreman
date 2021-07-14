import React from 'react';
import { Route } from 'react-router-dom';
import PropTypes from 'prop-types';
import { routes } from './routes';
import { renderRoute } from './RoutingService';
import ForemanSwitch from './ForemanSwitcher';
import componentRegistry from '../components/componentRegistry';

const AppSwitcher = ({ children, serverRoutes }) => {
  const appRoutes = [
    ...routes,
    ...serverRoutes.map(({ path, props: serverProps, component }) => {
      const Component = componentRegistry.registry[component]?.type;
      return {
        path,
        render: renderProps =>
          Component && <Component {...renderProps} {...serverProps} />,
      };
    }),
  ];

  return (
    <>
      <ForemanSwitch>
        {appRoutes.map(({ render, path, ...routeProps }) => (
          <Route
            path={path}
            key={path}
            {...routeProps}
            render={renderProps => renderRoute(render, renderProps)}
          />
        ))}
      </ForemanSwitch>
      {children}
    </>
  );
};

AppSwitcher.propTypes = {
  children: PropTypes.object,
  serverRoutes: PropTypes.array,
};

AppSwitcher.defaultProps = {
  children: null,
  serverRoutes: [],
};

export default AppSwitcher;
