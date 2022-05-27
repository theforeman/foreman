import React from 'react';
import PropTypes from 'prop-types';
import { useSelector } from 'react-redux';
import { DescriptionList } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import Slot from '../../common/Slot';
import CardTemplate from '../Templates/CardItem/CardTemplate';
import { selectFillsAmount } from '../../common/Slot/SlotSelectors';

const RecentCommunicationCard = ({ hostDetails }) => {
  const itemCount = useSelector(state =>
    selectFillsAmount(state, 'recent-communication-card-item')
  );
  if (!itemCount) return null;
  return (
    <CardTemplate header={__('Recent communication')}>
      <DescriptionList isHorizontal>
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
  hostDetails: PropTypes.shape({}),
};

RecentCommunicationCard.defaultProps = {
  hostDetails: {},
};
