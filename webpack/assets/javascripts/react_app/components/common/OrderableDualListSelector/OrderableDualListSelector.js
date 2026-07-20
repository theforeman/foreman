import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  DragDrop,
  Droppable,
  DualListSelector,
  DualListSelectorPane,
  DualListSelectorList,
  DualListSelectorControlsWrapper,
  DualListSelectorControl,
} from '@patternfly/react-core';
import {
  AngleDoubleLeftIcon,
  AngleLeftIcon,
  AngleDoubleRightIcon,
  AngleRightIcon,
} from '@patternfly/react-icons';

import { translate as __, sprintf } from '../../../common/I18n';
import { noop } from '../../../common/helpers';
import DualListOptionItem from './DualListOptionItem';
import {
  appendUniqueOptions,
  moveItems,
  normalizeOptions,
  optionsToNames,
  reorderChosen,
} from './helpers';

const defaultSelectState = { availableSelected: [], chosenSelected: [] };

/**
 * PF5 composable dual list selector with drag-and-drop reordering on the chosen pane.
 * The parent owns available and chosen option lists and receives updates via onListChange.
 * Options may be strings or { label, value } objects.
 */
const OrderableDualListSelector = ({
  id,
  availableOptions,
  chosenOptions,
  onListChange,
  availableOptionsTitle,
  chosenOptionsTitle,
  isDisabled,
  showTooltips,
}) => {
  const available = normalizeOptions(availableOptions);
  const chosen = normalizeOptions(chosenOptions);
  const returnStrings =
    (availableOptions.length > 0 || chosenOptions.length > 0) &&
    [...availableOptions, ...chosenOptions].every(
      option => typeof option === 'string'
    );
  const [selectState, setSelectState] = useState(defaultSelectState);
  const [ignoreNextOptionSelect, setIgnoreNextOptionSelect] = useState(false);
  const availableSelectedSet = new Set(selectState.availableSelected);
  const chosenSelectedSet = new Set(selectState.chosenSelected);
  const selectedSets = {
    availableSelected: availableSelectedSet,
    chosenSelected: chosenSelectedSet,
  };

  const emitListChange = (nextAvailable, nextChosen) => {
    if (returnStrings) {
      onListChange(optionsToNames(nextAvailable), optionsToNames(nextChosen));
      return;
    }

    onListChange(nextAvailable, nextChosen);
  };

  const isItemSelected = stateName => value =>
    selectedSets[stateName].has(String(value));

  const onItemClick = stateName => value => () => {
    if (ignoreNextOptionSelect) {
      setIgnoreNextOptionSelect(false);
      return;
    }

    const valueKey = String(value);
    if (isItemSelected(stateName)(valueKey)) {
      setSelectState({
        ...selectState,
        [stateName]: selectState[stateName].filter(item => item !== valueKey),
      });
    } else {
      setSelectState({
        ...selectState,
        [stateName]: [...selectState[stateName], valueKey],
      });
    }
  };

  const onMoveSelected = fromAvailable => {
    if (fromAvailable) {
      const [newAvailable, newChosen] = moveItems(
        available,
        chosen,
        selectState.availableSelected
      );
      setSelectState({ ...selectState, availableSelected: [] });
      emitListChange(newAvailable, newChosen);
    } else {
      const [newChosen, newAvailable] = moveItems(
        chosen,
        available,
        selectState.chosenSelected
      );
      setSelectState({ ...selectState, chosenSelected: [] });
      emitListChange(newAvailable, newChosen);
    }
  };

  const onMoveAll = fromAvailable => {
    if (fromAvailable) {
      setSelectState({ ...selectState, availableSelected: [] });
      emitListChange([], appendUniqueOptions(chosen, available));
    } else {
      setSelectState({ ...selectState, chosenSelected: [] });
      emitListChange(appendUniqueOptions(available, chosen), []);
    }
  };

  const onDrop = (source, dest) => {
    if (!dest) {
      return false;
    }

    const nextChosen = reorderChosen(chosen, source.index, dest.index);
    emitListChange(available, nextChosen);
    return true;
  };

  return (
    <DualListSelector id={id}>
      <DualListSelectorPane
        title={availableOptionsTitle}
        status={sprintf(
          __('%s of %s items selected'),
          selectState.availableSelected.length,
          available.length
        )}
        isDisabled={isDisabled}
      >
        <DualListSelectorList>
          {available.map(option => (
            <DualListOptionItem
              key={option.value}
              label={option.label}
              isSelected={isItemSelected('availableSelected')(option.value)}
              id={`${id}-available-${option.value}`}
              onOptionSelect={onItemClick('availableSelected')(option.value)}
              isDisabled={isDisabled}
              showTooltip={showTooltips}
            />
          ))}
        </DualListSelectorList>
      </DualListSelectorPane>
      <DualListSelectorControlsWrapper>
        <DualListSelectorControl
          isDisabled={isDisabled || selectState.availableSelected.length === 0}
          onClick={() => onMoveSelected(true)}
          aria-label={__('Add selected')}
        >
          <AngleRightIcon />
        </DualListSelectorControl>
        <DualListSelectorControl
          isDisabled={isDisabled || available.length === 0}
          onClick={() => onMoveAll(true)}
          aria-label={__('Add all')}
        >
          <AngleDoubleRightIcon />
        </DualListSelectorControl>
        <DualListSelectorControl
          isDisabled={isDisabled || chosen.length === 0}
          onClick={() => onMoveAll(false)}
          aria-label={__('Remove all')}
        >
          <AngleDoubleLeftIcon />
        </DualListSelectorControl>
        <DualListSelectorControl
          isDisabled={isDisabled || selectState.chosenSelected.length === 0}
          onClick={() => onMoveSelected(false)}
          aria-label={__('Remove selected')}
        >
          <AngleLeftIcon />
        </DualListSelectorControl>
      </DualListSelectorControlsWrapper>
      <DragDrop
        onDrag={() => {
          setIgnoreNextOptionSelect(true);
          return true;
        }}
        onDrop={onDrop}
      >
        <DualListSelectorPane
          title={chosenOptionsTitle}
          status={sprintf(
            __('%s of %s items selected'),
            selectState.chosenSelected.length,
            chosen.length
          )}
          isChosen
          isDisabled={isDisabled}
        >
          <Droppable hasNoWrapper>
            <DualListSelectorList>
              {chosen.map(option => (
                <DualListOptionItem
                  key={option.value}
                  label={option.label}
                  isSelected={isItemSelected('chosenSelected')(option.value)}
                  id={`${id}-chosen-${option.value}`}
                  onOptionSelect={onItemClick('chosenSelected')(option.value)}
                  isDraggable={!isDisabled}
                  isDisabled={isDisabled}
                  showTooltip={showTooltips}
                />
              ))}
            </DualListSelectorList>
          </Droppable>
        </DualListSelectorPane>
      </DragDrop>
    </DualListSelector>
  );
};

OrderableDualListSelector.propTypes = {
  id: PropTypes.string.isRequired,
  availableOptions: PropTypes.arrayOf(
    PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.shape({
        label: PropTypes.string.isRequired,
        value: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
          .isRequired,
      }),
    ])
  ).isRequired,
  chosenOptions: PropTypes.arrayOf(
    PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.shape({
        label: PropTypes.string.isRequired,
        value: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
          .isRequired,
      }),
    ])
  ).isRequired,
  onListChange: PropTypes.func,
  availableOptionsTitle: PropTypes.string,
  chosenOptionsTitle: PropTypes.string,
  isDisabled: PropTypes.bool,
  showTooltips: PropTypes.bool,
};

OrderableDualListSelector.defaultProps = {
  onListChange: noop,
  availableOptionsTitle: __('Available options'),
  chosenOptionsTitle: __('Chosen options'),
  isDisabled: false,
  showTooltips: true,
};

export default OrderableDualListSelector;
