import PropTypes from 'prop-types';
import React, { useEffect, useContext } from 'react';
import { Flex, FlexItem, Button } from '@patternfly/react-core';
import { registerCoreCards } from './CardRegistry';
import Slot from '../../../common/Slot';
import { STATUS } from '../../../../constants';
import '../Overview/styles.css';
import './DetailsCard.scss';
import { translate as __ } from '../../../../common/I18n';
import { CardExpansionContext } from '../../CardExpansionContext';

const DetailsTab = ({ response, status, hostName }) => {
  useEffect(() => {
    //  This is a workaround for adding a gray background inspired by PF4 design
    //  TODO: delete it when PF4 layout (Page component) is implemented in Foreman
    document.body.classList.add('pf-gray-background');
    registerCoreCards();
    return () => document.body.classList.remove('pf-gray-background');
  }, []);
  const { cardExpandStates, dispatch } = useContext(CardExpansionContext);
  const areAllCardsExpanded = Object.values(cardExpandStates).every(
    value => value === true
  );

  const expandAllCards = () => dispatch({ type: 'expandAll' });

  const collapseAllCards = () => dispatch({ type: 'collapseAll' });

  const buttonText = areAllCardsExpanded
    ? __('Collapse all cards')
    : __('Expand all cards');

  return (
    <div className="host-details-tab-item details-tab">
      <Flex style={{ marginBottom: '1rem' }}>
        <FlexItem align={{ default: 'alignLeft' }}>
          <Button
            ouiaId="expand-button"
            onClick={areAllCardsExpanded ? collapseAllCards : expandAllCards}
            variant="link"
          >
            {buttonText}
          </Button>
        </FlexItem>
      </Flex>
      <div className="masonry-root">
        <Slot
          hostDetails={response}
          status={status}
          hostName={hostName}
          id="host-tab-details-cards"
          multi
        />
      </div>
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
