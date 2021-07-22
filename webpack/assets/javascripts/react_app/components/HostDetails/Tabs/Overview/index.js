import PropTypes from 'prop-types';
import React from 'react';
import { Grid, GridItem, Flex, FlexItem } from '@patternfly/react-core';

import Properties from '../../Properties';
import AuditCard from '../../Audits';
import StatusAlert from '../../Status';
import Slot from '../../../common/Slot';
import { STATUS } from '../../../../constants';
import './Details.css';

const DetailsTab = ({ response, status, hostName }) => (
  <div className="host-details-tab-item details-tab">
    <Flex
      spaceItems={{ modifier: 'spaceItemsXl' }}
      direction={{ default: 'column' }}
      style={{ paddingBottom: '10px' }}
    >
      <FlexItem alignSelf={{ default: 'alignSelfCenter' }}>
        <StatusAlert status={response ? response.global_status_label : null} />
      </FlexItem>
    </Flex>
    <Grid hasGutter>
      <GridItem xl2={2} md={3} lg={2} rowSpan={3}>
        <Properties hostData={response} status={status} />
      </GridItem>
      <GridItem xl2={3} md={6} lg={5}>
        <AuditCard hostName={hostName} />
      </GridItem>
      <Slot hostDetails={response} id="details-cards" multi />
    </Grid>
  </div>
);

DetailsTab.propTypes = {
  response: PropTypes.object,
  status: PropTypes.string,
  hostName: PropTypes.string,
};

DetailsTab.defaultProps = {
  response: {},
  status: STATUS.PENDING,
  hostName: undefined,
};
export default DetailsTab;
