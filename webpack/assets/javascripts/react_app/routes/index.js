import React from 'react';
import { Switch, Route } from 'react-router-dom';

// Pages
import Audits from './Audits';

export const pages = [Audits];

let currentLocation = null;
export default (
  <Switch>
    {pages.map(({ render, ...props }) => (
      <Route
        {...props}
        key={props.path}
        render={renderProps => {
          const railsApplicationContent = document.getElementById(
            'rails-application-content'
          );
          if (railsApplicationContent) {
            railsApplicationContent.remove();
          }
          currentLocation = renderProps.location;
          return render(renderProps);
        }}
      />
    ))}
    <Route
      render={({ location }) => {
        if (currentLocation && currentLocation.pathname !== location.pathname) {
          window.Turbolinks.visit(location.pathname);
        }
        currentLocation = location;
        return null;
      }}
    />
  </Switch>
);
