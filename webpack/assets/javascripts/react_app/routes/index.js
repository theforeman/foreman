import React from 'react';
import { Route } from 'react-router-dom';
import PropTypes from 'prop-types';
import { routes } from './routes';
import { renderRoute } from './RoutingService';
import ForemanSwitch from './ForemanSwitcher';
import templates from './routerTemplates';

const AppSwitcher = ({ children, serverRoutes }) => {
  const appRoutes = [
    ...routes,
    ...serverRoutes.map(({ path, props: serverProps, component }) => {
      const Template = templates[component];
      return {
        path,
        render: renderProps =>
          Template && <Template {...renderProps} {...serverProps} />,
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
