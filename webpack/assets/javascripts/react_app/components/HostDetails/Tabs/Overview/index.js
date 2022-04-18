import PropTypes from 'prop-types';
import React, { useEffect } from 'react';
import { Grid } from '@patternfly/react-core';
import { registerCoreCards } from './CardsRegistry';
import Slot from '../../../common/Slot';
import { STATUS } from '../../../../constants';
import './styles.css';

const OverviewTab = ({ response, status, hostName }) => {
  useEffect(() => {
    //  This is a workaround for adding gray background inspiring pf4 desgin
    //  TODO: delete it when pf4 layout (Page copmponent) is implemented in foreman
    document.body.classList.add('pf-gray-background');
    registerCoreCards();
    return () => document.body.classList.remove('pf-gray-background');
  }, []);

  return (
    <div className="host-details-tab-item details-tab">
      <Grid hasGutter>
        <Slot
          hostDetails={response}
          status={status}
          hostName={hostName}
          id="host-overview-cards"
          multi
        />
        <Slot
          deprecated
          replacedBy="host-overview-cards"
          hostDetails={response}
          status={status}
          hostName={hostName}
          id="details-cards"
          multi
        />
      </Grid>
    </div>
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
