import React from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  DescriptionList,
  DescriptionListGroup,
  DescriptionListTerm,
  DescriptionListDescription,
} from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import Slot from '../../common/Slot';
import CardTemplate from '../Templates/CardItem/CardTemplate';
import RelativeDateTime from '../../common/dates/RelativeDateTime';

const RecentCommunicationCard = ({ hostName, hostDetails }) => {
  const lastReport = hostDetails.last_report;
  return (
    <CardTemplate header={__('Recent communication')}>
      <DescriptionList isHorizontal>
        <DescriptionListGroup>
          <DescriptionListTerm>
            {__('Last configuration report')}
          </DescriptionListTerm>
          <DescriptionListDescription>
            <Button
              ouiaId="last-report-button"
              variant="link"
              component="a"
              isInline
              isDisabled={!lastReport?.length}
              href={`/hosts/${hostName}/config_reports/last`}
            >
              <RelativeDateTime date={lastReport} defaultValue={__('Never')} />
            </Button>
          </DescriptionListDescription>
        </DescriptionListGroup>
        <Slot
          hostDetails={hostDetails}
          id="recent-communication-card-item"
          multi
        />
      </DescriptionList>
    </CardTemplate>
  );
};

export default RecentCommunicationCard;

RecentCommunicationCard.propTypes = {
  hostName: PropTypes.string,
  hostDetails: PropTypes.shape({ last_report: PropTypes.string }),
};

RecentCommunicationCard.defaultProps = {
  hostName: '',
  hostDetails: {},
};
