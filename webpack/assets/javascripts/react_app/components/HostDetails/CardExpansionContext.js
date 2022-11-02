import PropTypes from 'prop-types';
import React, { useEffect, useReducer, useCallback } from 'react';

export const CardExpansionContext = React.createContext({});

const cardExpansionReducer = (state, action) => {
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
      throw new Error(`invalid card expansion type: ${action.type}`);
  }
};

export const CardExpansionContextWrapper = ({ children }) => {
  const [cardExpandStates, dispatch] = useReducer(cardExpansionReducer, {});
  // On mount, get values from localStorage and set them in state
  const initializeCardFromLocalStorage = useCallback(key => {
    const value = localStorage.getItem(`${key} card expanded`);
    if (value !== null && value !== undefined) {
      dispatch({ type: value === 'true' ? 'expand' : 'collapse', key });
    } else {
      dispatch({ type: 'add', key });
    }
  }, []);
  // On unmount, save the values to local storage
  // eslint-disable-next-line arrow-body-style
  useEffect(() => {
    return () =>
      Object.entries(cardExpandStates).forEach(([key, value]) =>
        localStorage.setItem(`${key} card expanded`, value)
      );
  });
  return (
    <CardExpansionContext.Provider
      value={{
        cardExpandStates,
        dispatch,
        registerCard: initializeCardFromLocalStorage,
      }}
    >
      {children}
    </CardExpansionContext.Provider>
  );
};

CardExpansionContextWrapper.propTypes = {
  children: PropTypes.node.isRequired,
};
