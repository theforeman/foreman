import React from 'react';
import { Route } from 'react-router-dom';
import PropTypes from 'prop-types';
import { layoutPropTypes } from '../components/Layout/Layout';
import RouteWithLayout from './RouteWithLayout';
import { noop } from '../common/helpers';

const ForemanRoute = ({
  render,
  layout,
  skipLayout,
  beforeRender,
  path,
  ...routeProps
}) => {
  if (skipLayout) {
    return (
      <Route
        path={path}
        key={path}
        {...routeProps}
        render={renderProps => {
          beforeRender(renderProps);

          return render(renderProps);
        }}
      />
    );
  }
  return (
    <RouteWithLayout
      path={path}
      key={path}
      render={renderProps => {
        beforeRender(renderProps);

        return render(renderProps);
      }}
      layout={layout}
    />
  );
};

export default ForemanRoute;

delete layoutPropTypes.history;

ForemanRoute.propTypes = {
  render: PropTypes.func.isRequired,
  layout: PropTypes.shape(layoutPropTypes).isRequired,
  beforeRender: PropTypes.func,
  path: PropTypes.string.isRequired,
  skipLayout: PropTypes.bool,
};

ForemanRoute.defaultProps = {
  beforeRender: noop,
  skipLayout: false,
};
