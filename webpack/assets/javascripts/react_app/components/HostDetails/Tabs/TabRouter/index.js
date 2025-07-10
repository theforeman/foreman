import PropTypes from 'prop-types';
import React from 'react';
import { PageSection } from '@patternfly/react-core';
import {
  HashRouter,
  Route,
  Routes,
  Navigate,
} from 'react-router-dom';
import { STATUS } from '../../../../constants';
import Slot from '../../../common/Slot';
import { DEFAULT_TAB } from '../../consts';
import TabsWithHashHistory from './Tabs';

const TabRouter = ({ children, tabs, hostName, response, status, router }) => (
  <HashRouter>
    <PageSection
      variant="light"
      padding={{ default: 'noPadding' }}
      className="host-details-tabs-section"
    >
      <TabsWithHashHistory tabs={children} />
    </PageSection>
    <Routes>
      <Route path="/" element={<Navigate to={`/${DEFAULT_TAB}`} replace />} />
      {tabs.map(tab => (
        <Route
          key={tab}
          path={`/${tab}`}
          element={
            <Slot
              hostName={hostName}
              response={response}
              status={status}
              id="host-details-page-tabs"
              fillID={tab}
              router={router}
            />
          }
        />
      ))}
    </Routes>
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
