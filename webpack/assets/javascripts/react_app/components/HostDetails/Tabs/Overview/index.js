import PropTypes from 'prop-types';
import React, { useEffect } from 'react';
import { PageSection, Grid } from '@patternfly/react-core';
import { registerCoreCards } from './CardsRegistry';
import Slot from '../../../common/Slot';
import { STATUS } from '../../../../constants';

const OverviewTab = ({ response, status, hostName }) => {
  useEffect(() => {
    registerCoreCards();
  }, []);

  return (
    <PageSection className="host-details-cards-section">
      <div className="host-details-tab-item details-tab host-details-cards-section">
        <Grid hasGutter>
          <Slot
            hostDetails={response}
            status={status}
            hostName={hostName}
            id="host-overview-cards"
            multi
          />
        </Grid>
      </div>
    </PageSection>
  );
};

OverviewTab.propTypes = {
  response: PropTypes.object,
  status: PropTypes.string,
  hostName: PropTypes.string,
};

OverviewTab.defaultProps = {
  response: {},
  status: STATUS.PENDING,
  hostName: undefined,
};
export default OverviewTab;
