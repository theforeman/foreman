import PropTypes from 'prop-types';
import React from 'react';
import { HashRouter, Route, Redirect, Switch } from 'react-router-dom';
import { STATUS } from '../../../../constants';
import Slot from '../../../common/Slot';
import { DEFAULT_TAB } from '../../consts';
import TabsWithHashHistory from './Tabs';

const TabRouter = ({ children, tabs, hostName, response, status, router }) => (
  <HashRouter>
    <>
      <TabsWithHashHistory tabs={children} />
      <Switch>
        <Route path="/" exact>
          <Redirect to={`/${DEFAULT_TAB}`} />
        </Route>
        {tabs.map(tab => (
          <Route
            key={tab}
            path={`/${tab}`}
            render={props => (
              <Slot
                hostName={hostName}
                response={response}
                status={status}
                id="host-details-page-tabs"
                fillID={tab}
                router={router}
                {...props}
              />
            )}
          />
        ))}
      </Switch>
    </>
  </HashRouter>
);

TabRouter.propTypes = {
  children: PropTypes.node.isRequired,
  hostName: PropTypes.string.isRequired,
  status: PropTypes.string,
  response: PropTypes.object,
  tabs: PropTypes.array.isRequired,
  router: PropTypes.object.isRequired,
};

TabRouter.defaultProps = {
  status: STATUS.PENDING,
  response: undefined,
};

export default TabRouter;
