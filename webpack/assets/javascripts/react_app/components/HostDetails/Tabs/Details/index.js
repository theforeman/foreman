import PropTypes from 'prop-types';
import React from 'react';
import { Grid, GridItem, Flex, FlexItem } from '@patternfly/react-core';

import Properties from '../../Properties';
import ParametersCard from '../../Parameters';
import InterfacesCard from '../../Interfaces';
import AuditCard from '../../Audits';
import StatusAlert from '../../Status';
import Slot from '../../../common/Slot';
import AggregateStatus from '../../AggregateStatusCard';
import './Details.css';

const DetailsTab = ({ response }) => (
  <div className="details-tab">
    <Grid hasGutter className="details-cards">
      <GridItem span={3} rowSpan={3}>
        <Properties hostData={response} />
      </GridItem>
      <GridItem xl2={3} md={6} lg={5}>
        <ParametersCard paramters={response.all_parameters} />
      </GridItem>
      <GridItem xl2={3} md={6} lg={5}>
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
  }).isRequired,
};

export default DetailsTab;
