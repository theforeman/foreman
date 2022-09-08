import PropTypes from 'prop-types';
import React, { useEffect, useReducer, useRef } from 'react';
import { useSelector } from 'react-redux';
import { Flex, FlexItem, Button } from '@patternfly/react-core';
import { registerCoreCards } from './CardRegistry';
import Slot from '../../../common/Slot';
import { STATUS } from '../../../../constants';
import '../Overview/styles.css';
import './styles.css';
import { translate as __ } from '../../../../common/I18n';
import { selectFillsIDs } from '../../../common/Slot/SlotSelectors';

export const CardExpansionContext = React.createContext({});

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
    case 'add':
      if (state[action.key] === undefined) {
        return {
          ...state,
          [action.key]: true,
        };
      }
      return state;
    case 'expandAll': {
      const expandedState = {};
      Object.keys(state).forEach(key => {
        expandedState[key] = true;
      });
      return expandedState;
    }
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

  const cardIds = useSelector(state =>
    selectFillsIDs(state, 'host-tab-details-cards')
  );

  const getInitialState = keys => {
    const state = {};
    if (!keys) return state;
    keys.forEach(key => {
      const value = localStorage.getItem(`${key} card expanded`);
      if (value !== null && value !== undefined) {
        state[key] = value === 'true';
      } else {
        state[key] = true;
      }
    });
    return state;
  };

  // React calls getInitialState(cardIds) to get the initial state
  // This ensures card states persist when you switch tabs
  const [cardExpandStates, dispatch] = useReducer(
    cardExpansionReducer,
    cardIds,
    getInitialState
  );
  const areAllCardsExpanded = Object.values(cardExpandStates).every(
    value => value === true
  );

  const expandAllCards = () => dispatch({ type: 'expandAll' });

  const collapseAllCards = () => dispatch({ type: 'collapseAll' });

  const cardCount = useRef(cardIds?.length || 0);

  // On mount, get values from localStorage and set them in state
  useEffect(() => {
    if (cardIds?.length && cardIds.length !== cardCount.current) {
      cardIds.forEach(key => {
        const value = localStorage.getItem(`${key} card expanded`);
        if (value !== null && value !== undefined) {
          dispatch({ type: value === 'true' ? 'expand' : 'collapse', key });
        } else {
          dispatch({ type: 'add', key });
        }
      });
      cardCount.current = cardIds.length;
    }
  }, [cardIds]);

  // On unmount, save the values to local storage
  // eslint-disable-next-line arrow-body-style
  useEffect(() => {
    return () =>
      Object.entries(cardExpandStates).forEach(([key, value]) =>
        localStorage.setItem(`${key} card expanded`, value)
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
        <CardExpansionContext.Provider
          value={{ cardExpandStates, dispatch, cardIds }}
        >
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
