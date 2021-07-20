import PropTypes from 'prop-types';
import React from 'react';
import { Grid, GridItem, Flex, FlexItem } from '@patternfly/react-core';

import ParametersCard from '../../Parameters';
import InterfacesCard from '../../Interfaces';
import AuditCard from '../../Audits';
import StatusAlert from '../../Status';
import Slot from '../../../common/Slot';
import DetailsCard from '../../DetailsCard';
import { STATUS } from '../../../../constants';
import './Details.css';

const DetailsTab = ({ response, status }) => (
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
      <GridItem xl2={3} md={6} lg={4} rowSpan={3}>
        <DetailsCard {...response} status={status} />
      </GridItem>
      <GridItem xl2={3} md={6} lg={5}>
        <ParametersCard paramters={response.all_parameters} />
      </GridItem>
      <GridItem xl2={3} md={6} lg={4}>
        <AuditCard hostName={response.name} />
      </GridItem>
      <GridItem xl2={3} md={6} lg={5}>
        <InterfacesCard interfaces={response.interfaces} />
      </GridItem>
      <Slot hostDetails={response} id="details-cards" multi />
    </Grid>
  </div>
);

DetailsTab.propTypes = {
  response: PropTypes.shape({
    all_parameters: PropTypes.string,
    global_status_label: PropTypes.string,
    interfaces: PropTypes.string,
    name: PropTypes.string,
  }),
  status: PropTypes.string,
};

DetailsTab.defaultProps = {
  response: {},
  status: STATUS.PENDING,
};
export default DetailsTab;
