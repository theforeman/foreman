import PropTypes from 'prop-types';
import React from 'react';
import { Grid, GridItem } from '@patternfly/react-core';

import Properties from '../../Properties';
import ParametersCard from '../../Parameters';
import InterfacesCard from '../../Interfaces';
import AuditCard from '../../Audits';
import StatusAlert from '../../Status';
import './Details.css';

const DetailsTab = ({ response }) => (
  <div className="details-tab">
    <Grid>
      <GridItem offset={3} span={4}>
        <StatusAlert status={response ? response.global_status_label : null} />
      </GridItem>
    </Grid>
    <Grid className="details-cards">
      <GridItem span={3} rowSpan={3}>
        <Properties hostData={response} />
      </GridItem>
      <GridItem style={{ marginLeft: '40px' }} span={3}>
        <ParametersCard paramters={response.all_parameters} />
      </GridItem>
      <GridItem style={{ marginLeft: '40px' }} span={3} rowSpan={2}>
        <AuditCard hostName={response.name} />
      </GridItem>
      <GridItem
        style={{ marginLeft: '40px', marginTop: '20px' }}
        offset={3}
        span={3}
      >
        <InterfacesCard interfaces={response.interfaces} />
      </GridItem>
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
