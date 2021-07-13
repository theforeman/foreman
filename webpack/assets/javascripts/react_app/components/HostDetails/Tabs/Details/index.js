import PropTypes from 'prop-types';
import React from 'react';
import { Grid } from '@patternfly/react-core';
import DetailsCardTemplate from '../../Templates/CardItem/DetailsCard';
import { translate as __ } from '../../../../common/I18n';
import { STATUS } from '../../../../constants';
import Slot from '../../../common/Slot/Slot';

const DetailsTab = ({ response, status }) => (
  <div className="host-details-tab-item details-tab">
    <Grid hasGutter>
      <DetailsCardTemplate
        status={status}
        overrideGridProps={{ rowSpan: 3 }}
        title={__('System Properties')}
        columnModifier={{ md: '1Col', lg: '2Col' }}
      >
        {[
          { name: 'Host Name', description: response.name },
          { name: 'Host Owner', description: response.owner_name },
          { name: 'Host Group', description: response.hostgroup_title },
          { name: 'Location', description: response.location_name },
          { name: 'Organization', description: response.organization_name },
          { name: 'Registered on', description: 'aa' },
          { name: 'Registered by', description: 'aa' },
          { name: 'Domain', description: 'example.com' },
        ]}
      </DetailsCardTemplate>
      <DetailsCardTemplate
        status={status}
        title={__('HW Properties')}
        columnModifier={{ md: '1Col', lg: '2Col' }}
      >
        {[
          { name: 'Number of CPU(s)', description: '2' },
          { name: 'Number of sockets', description: '2' },
          { name: 'Cores per socket', description: '1' },
          { name: 'RAM (GB)', description: '4' },
          { name: 'Storage', description: '100' },
          { name: 'Model', description: 'Model' },
        ]}
      </DetailsCardTemplate>
      <DetailsCardTemplate
        status={status}
        title={__('Infrastructure')}
        columnModifier={{ md: '1Col', lg: '2Col' }}
      >
        {[
          { name: 'type', description: 'Primary' },
          { name: 'IPv4 Address', description: response.ip },
          { name: 'IPv6 Address', description: response.ip6 },
          { name: 'MAC Address', description: response.mac },
          { name: 'Interfaces', description: 'To be continue' },
        ]}
      </DetailsCardTemplate>
      <Slot hostDetails={response} id="details-tab-cards" multi />
    </Grid>
  </div>
);

DetailsTab.propTypes = {
  response: PropTypes.object,
  status: PropTypes.string,
};

DetailsTab.defaultProps = {
  response: {},
  status: STATUS.PENDING,
};
export default DetailsTab;
