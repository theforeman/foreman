import PropTypes from 'prop-types';
import React, { useEffect, useState } from 'react';
import { Grid, Flex, FlexItem, Button } from '@patternfly/react-core';
import { registerCoreCards } from './CardRegistry';
import Slot from '../../../common/Slot';
import { STATUS } from '../../../../constants';
import '../Overview/styles.css';
import { translate as __ } from '../../../../common/I18n';

const DetailsTab = ({ response, status, hostName }) => {
  useEffect(() => {
    //  This is a workaround for adding a gray background inspired by PF4 design
    //  TODO: delete it when PF4 layout (Page component) is implemented in Foreman
    document.body.classList.add('pf-gray-background');
    registerCoreCards();
    return () => document.body.classList.remove('pf-gray-background');
  }, []);
  const [isExpandedGlobal, setExpandedGlobal] = useState(true);

  return (
    <div className="host-details-tab-item details-tab">
      <Flex>
        <FlexItem align={{ default: 'alignRight' }}>
          <Button
            onClick={() => setExpandedGlobal(prev => !prev)}
            variant="link"
          >
            {__('Expand/Collapse  all')}
          </Button>
        </FlexItem>
      </Flex>
      <Grid hasGutter>
        <Slot
          hostDetails={response}
          status={status}
          hostName={hostName}
          id="host-tab-details-cards"
          isExpandedGlobal={isExpandedGlobal}
          multi
        />
      </Grid>
    </div>
  );
};

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
