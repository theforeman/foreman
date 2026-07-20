import React, { useEffect, useRef, useState } from 'react';
import PropTypes from 'prop-types';
import {
  Draggable,
  DualListSelectorListItem,
  Tooltip,
} from '@patternfly/react-core';

const TOOLTIP_ENTRY_DELAY = 500;
const TOOLTIP_EXIT_DELAY = 100;

const DualListOptionItem = ({
  label,
  isSelected,
  id,
  onOptionSelect,
  isDraggable,
  isDisabled,
  showTooltip,
}) => {
  const [tooltipTrigger, setTooltipTrigger] = useState(null);
  const [tooltipVisible, setTooltipVisible] = useState(false);
  const showTimerRef = useRef();
  const hideTimerRef = useRef();
  const isDraggingRef = useRef(false);

  useEffect(
    () => () => {
      clearTimeout(showTimerRef.current);
      clearTimeout(hideTimerRef.current);
    },
    []
  );

  useEffect(() => {
    if (!tooltipTrigger || !showTooltip || !isDraggable) {
      return undefined;
    }

    const onDragStart = () => {
      isDraggingRef.current = true;
      clearTimeout(showTimerRef.current);
      clearTimeout(hideTimerRef.current);
      setTooltipVisible(false);
    };

    const onDragEnd = () => {
      isDraggingRef.current = false;
    };

    tooltipTrigger.addEventListener('dragstart', onDragStart);
    document.addEventListener('mouseup', onDragEnd);

    return () => {
      tooltipTrigger.removeEventListener('dragstart', onDragStart);
      document.removeEventListener('mouseup', onDragEnd);
    };
  }, [tooltipTrigger, showTooltip, isDraggable]);

  const showTooltipHandler = () => {
    if (!showTooltip || isDraggingRef.current) {
      return;
    }
    clearTimeout(hideTimerRef.current);
    showTimerRef.current = setTimeout(() => {
      if (!isDraggingRef.current) {
        setTooltipVisible(true);
      }
    }, TOOLTIP_ENTRY_DELAY);
  };

  const hideTooltipHandler = () => {
    clearTimeout(showTimerRef.current);
    hideTimerRef.current = setTimeout(
      () => setTooltipVisible(false),
      TOOLTIP_EXIT_DELAY
    );
  };

  const listItem = (
    <DualListSelectorListItem
      ref={setTooltipTrigger}
      isSelected={isSelected}
      id={id}
      onOptionSelect={onOptionSelect}
      onMouseEnter={showTooltipHandler}
      onMouseLeave={hideTooltipHandler}
      isDraggable={isDraggable}
      isDisabled={isDisabled}
    >
      {label}
    </DualListSelectorListItem>
  );

  return (
    <>
      {isDraggable ? <Draggable hasNoWrapper>{listItem}</Draggable> : listItem}
      {showTooltip && tooltipTrigger && (
        <Tooltip
          content={label}
          trigger="manual"
          isVisible={tooltipVisible}
          triggerRef={() => tooltipTrigger}
          entryDelay={0}
          exitDelay={0}
          aria="none"
        />
      )}
    </>
  );
};

DualListOptionItem.propTypes = {
  label: PropTypes.string.isRequired,
  isSelected: PropTypes.bool.isRequired,
  id: PropTypes.string.isRequired,
  onOptionSelect: PropTypes.func.isRequired,
  isDraggable: PropTypes.bool,
  isDisabled: PropTypes.bool,
  showTooltip: PropTypes.bool,
};

DualListOptionItem.defaultProps = {
  isDraggable: false,
  isDisabled: false,
  showTooltip: true,
};

export default DualListOptionItem;
