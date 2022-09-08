import PropTypes from 'prop-types';
import React, { useEffect, useReducer } from 'react';
import { Flex, FlexItem, Button } from '@patternfly/react-core';
import { registerCoreCards } from './CardRegistry';
import Slot from '../../../common/Slot';
import { STATUS } from '../../../../constants';
import '../Overview/styles.css';
import './styles.css';
import { translate as __ } from '../../../../common/I18n';

export const CardExpansionContext = React.createContext({});

const initialState = {
  'System properties card expanded': true,
  'Operating system card expanded': true,
  'Registration details card expanded': true,
  'HW properties card expanded': true,
  'Installed products card expanded': true,
};

function cardExpansionReducer(state, action) {
  // A React reducer, not a Redux one!
  switch (action.type) {
    case 'expand':
      return {
        ...state,
        [action.key]: true,
      };
    case 'collapse':
      return {
        ...state,
        [action.key]: false,
      };
    case 'expandAll':
      return initialState;
    case 'collapseAll': {
      const collapsedState = {};
      Object.keys(state).forEach(key => {
        collapsedState[key] = false;
      });
      return collapsedState;
    }
    default:
      throw new Error();
  }
}

const DetailsTab = ({ response, status, hostName }) => {
  useEffect(() => {
    //  This is a workaround for adding a gray background inspired by PF4 design
    //  TODO: delete it when PF4 layout (Page component) is implemented in Foreman
    document.body.classList.add('pf-gray-background');
    registerCoreCards();
    return () => document.body.classList.remove('pf-gray-background');
  }, []);

  const [cardExpandStates, dispatch] = useReducer(
    cardExpansionReducer,
    initialState
  );
  const areAllCardsExpanded = Object.values(cardExpandStates).every(
    value => value === true
  );

  const expandAllCards = () => dispatch({ type: 'expandAll' });

  const collapseAllCards = () => dispatch({ type: 'collapseAll' });

  // On mount, get values from localStorage and set them in state
  useEffect(() => {
    Object.keys(initialState).forEach(key => {
      const value = localStorage.getItem(key);
      if (value !== null) {
        dispatch({ type: value === 'true' ? 'expand' : 'collapse', key });
      }
    });
  }, []);

  // On unmount, save the values to local storage
  // eslint-disable-next-line arrow-body-style
  useEffect(() => {
    return () =>
      Object.entries(cardExpandStates).forEach(([key, value]) =>
        localStorage.setItem(key, value)
      );
  });

  const buttonText = areAllCardsExpanded
    ? __('Collapse all cards')
    : __('Expand all cards');

  return (
    <div className="host-details-tab-item details-tab">
      <Flex style={{ marginBottom: '1rem' }}>
        <FlexItem align={{ default: 'alignRight' }}>
          <Button
            ouiaId="expand-button"
            onClick={areAllCardsExpanded ? collapseAllCards : expandAllCards}
            variant="link"
          >
            {buttonText}
          </Button>
        </FlexItem>
      </Flex>
      <Flex
        direction={{ default: 'column' }}
        flexWrap={{ default: 'wrap' }}
        className="details-tab-flex-container"
      >
        <CardExpansionContext.Provider value={{ cardExpandStates, dispatch }}>
          <Slot
            hostDetails={response}
            status={status}
            hostName={hostName}
            id="host-tab-details-cards"
            multi
          />
        </CardExpansionContext.Provider>
      </Flex>
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
