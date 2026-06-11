import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  DataList,
  DataListItem,
  DataListCell,
  DataListItemRow,
  DataListControl,
  DataListDragButton,
  DataListItemCells,
  DataListAction,
  DragDrop,
  Draggable,
  Droppable,
  getUniqueId,
  MenuToggle,
  Select,
  SelectList,
  SelectOption,
} from '@patternfly/react-core';
import { TrashIcon } from '@patternfly/react-icons';

import { translate as __, sprintf } from '../../../../common/I18n';
import { noop } from '../../../../common/helpers';
import {
  createInitialChosen,
  getAvailableToAdd,
  reorderChosen,
  chosenValues,
  addToChosen,
  removeFromChosen,
  normalizeSelectedValues,
} from './helpers';

const OrderableDataList = ({
  id,
  name,
  options,
  value,
  defaultValue,
  disabled,
  onChange,
}) => {
  const resolvedValue = normalizeSelectedValues(
    value != null && value !== '' ? value : defaultValue
  );
  const [chosen, setChosen] = useState(() =>
    createInitialChosen(options, resolvedValue)
  );
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [liveText, setLiveText] = useState('');
  const uniqueId = getUniqueId();
  const availableToAdd = getAvailableToAdd(options, chosen);

  const updateChosen = nextChosen => {
    setChosen(nextChosen);
    onChange(chosenValues(nextChosen));
  };

  const addDevice = deviceValue => {
    const option = options.find(
      item => String(item.value) === String(deviceValue)
    );
    if (!option) {
      return;
    }

    updateChosen(addToChosen(chosen, option));
    setIsAddOpen(false);
  };

  const removeDevice = deviceValue => {
    updateChosen(removeFromChosen(chosen, deviceValue));
  };

  const onDrag = source => {
    setLiveText(
      sprintf(__('Started dragging %s'), chosen[source.index].label)
    );
    return true;
  };

  const onDrop = (source, dest) => {
    if (!dest) {
      setLiveText(__('Dragging cancelled. Boot order unchanged.'));
      return false;
    }

    updateChosen(reorderChosen(chosen, source.index, dest.index));
    setLiveText(__('Boot order updated.'));
    return true;
  };

  const renderChosenItems = () =>
    chosen.map(item => (
      <Draggable key={item.value} hasNoWrapper>
        <DataListItem
          aria-labelledby={`${id}-boot-${item.value}`}
          id={`${id}-boot-item-${item.value}`}
        >
          <DataListItemRow>
            <DataListControl>
              <DataListDragButton
                aria-label={__('Reorder')}
                aria-labelledby={`${id}-boot-${item.value}`}
                aria-describedby={`${id}-drag-help-${uniqueId}`}
                isDisabled={disabled}
              />
            </DataListControl>
            <DataListItemCells
              dataListCells={[
                <DataListCell key={item.value}>
                  <span id={`${id}-boot-${item.value}`}>{item.label}</span>
                </DataListCell>,
              ]}
            />
            <DataListAction
              aria-label={__('Remove boot device')}
              aria-labelledby={`${id}-boot-${item.value} ${id}-remove-${item.value}`}
              id={`${id}-remove-${item.value}`}
            >
              <Button
                variant="plain"
                isDisabled={disabled}
                onClick={() => removeDevice(item.value)}
                aria-label={sprintf(__('Remove %s'), item.label)}
              >
                <TrashIcon />
              </Button>
            </DataListAction>
          </DataListItemRow>
        </DataListItem>
      </Draggable>
    ));

  const renderEmptyItem = () => (
    <DataListItem aria-label={__('No boot devices selected')}>
      <DataListItemRow>
        <DataListItemCells
          dataListCells={[
            <DataListCell key="empty">
              {__(
                'No boot devices selected. Use "Add boot device" to build the boot sequence.'
              )}
            </DataListCell>,
          ]}
        />
      </DataListItemRow>
    </DataListItem>
  );

  return (
    <div id={id}>
      <Select
        isOpen={isAddOpen}
        selected={null}
        onSelect={(_event, selection) => addDevice(selection)}
        onOpenChange={setIsAddOpen}
        toggle={toggleRef => (
          <MenuToggle
            ref={toggleRef}
            onClick={() => setIsAddOpen(!isAddOpen)}
            isExpanded={isAddOpen}
            isDisabled={disabled || availableToAdd.length === 0}
            aria-label={__('Add boot device')}
          >
            {__('Add boot device')}
          </MenuToggle>
        )}
        aria-label={__('Add boot device')}
        ouiaId={`${id}-add-select`}
      >
        <SelectList>
          {availableToAdd.map(option => (
            <SelectOption key={option.value} value={option.value}>
              {option.label}
            </SelectOption>
          ))}
        </SelectList>
      </Select>

      <div className="pf-v5-u-mt-sm">
        <strong>{__('Boot order')}</strong>
      </div>

      {chosen.length === 0 ? (
        <DataList
          aria-label={__('Boot order')}
          isCompact
          className="pf-v5-u-mt-sm"
        >
          {renderEmptyItem()}
        </DataList>
      ) : (
        <DragDrop onDrag={onDrag} onDrop={onDrop}>
          <Droppable hasNoWrapper>
            <DataList
              aria-label={__('Boot order')}
              isCompact
              className="pf-v5-u-mt-sm"
            >
              {renderChosenItems()}
            </DataList>
          </Droppable>
          <div className="pf-v5-screen-reader" aria-live="assertive">
            {liveText}
          </div>
          <div
            className="pf-v5-screen-reader"
            id={`${id}-drag-help-${uniqueId}`}
          >
            {__(
              'Press space or enter to begin dragging, and use the arrow keys to navigate up or down. Press enter to confirm the drag, or any other key to cancel the drag operation.'
            )}
          </div>
        </DragDrop>
      )}

      {name &&
        chosen.map(item => (
          <input
            key={item.value}
            type="hidden"
            name={name}
            value={item.value}
          />
        ))}
    </div>
  );
};

OrderableDataList.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string,
  options: PropTypes.arrayOf(PropTypes.object),
  value: PropTypes.oneOfType([
    PropTypes.array,
    PropTypes.string,
    PropTypes.number,
  ]),
  defaultValue: PropTypes.oneOfType([
    PropTypes.array,
    PropTypes.string,
    PropTypes.number,
  ]),
  disabled: PropTypes.bool,
  onChange: PropTypes.func,
};

OrderableDataList.defaultProps = {
  name: null,
  options: [],
  value: null,
  defaultValue: [],
  disabled: false,
  onChange: noop,
};

export default OrderableDataList;
