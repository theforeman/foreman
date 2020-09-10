import React, { useImperativeHandle, useRef } from 'react';
import { DragSource, DropTarget } from 'react-dnd';
import PropTypes from 'prop-types';
import { set } from 'lodash';

export const orderDragged = (inputArray, dragIndex, hoverIndex) => {
  const dragedValue = inputArray[dragIndex];
  const ordered = [...inputArray];
  ordered.splice(dragIndex, 1);
  ordered.splice(hoverIndex, 0, dragedValue);
  return ordered;
};

export const makeOnHover = (getIndex, getMoveFnc) => (
  props,
  monitor,
  component
) => {
  const dragIndex = monitor.getItem().index;
  const hoverIndex = getIndex(props);

  // Don't replace items with themselves
  if (dragIndex === hoverIndex) return null;

  // Determine rectangle on screen
  const hoverBoundingRect = component.getNode().getBoundingClientRect();
  // Get vertical middle
  const hoverMiddleX = (hoverBoundingRect.right - hoverBoundingRect.left) / 2;
  // Determine mouse position
  const clientOffset = monitor.getClientOffset();
  // Get pixels to the top
  const hoverClientX = clientOffset.x - hoverBoundingRect.left;
  // Only perform the move when the mouse has crossed half of the items width
  // When dragging right, only move when the cursor is over 50%
  // When dragging left, only move when the cursor is under 50%
  // Dragging right
  if (dragIndex < hoverIndex && hoverClientX < hoverMiddleX) {
    return null;
  }
  // Dragging left
  if (dragIndex > hoverIndex && hoverClientX > hoverMiddleX) {
    return null;
  }
  // Time to actually perform the action
  getMoveFnc(props)(dragIndex, hoverIndex);
  // Note: we're mutating the monitor item here!
  // Generally it's better to avoid mutations,
  // but it's good here for the sake of performance
  // to avoid expensive index searches.
  monitor.getItem().index = hoverIndex;
  return null;
};

const getDropTarget = (dropTypes, getIndex, getMoveFnc) =>
  DropTarget(
    dropTypes,
    { hover: makeOnHover(getIndex, getMoveFnc) },
    connect => ({
      connectDropTarget: connect.dropTarget(),
    })
  );

const getDragSource = (dragType, getIndex, getItem) =>
  DragSource(
    dragType,
    {
      beginDrag: props => set(getItem(props), 'index', getIndex(props)),
    },
    (connect, monitor) => ({
      connectDragSource: connect.dragSource(),
      isDragging: monitor.isDragging(),
    })
  );

export const orderable = (
  Component,
  {
    type = 'orderable',
    getItem = props => ({ id: props.id }),
    getIndex = props => props.index,
    getMoveFnc = props => props.moveValue,
  }
) => {
  const Orderable = React.forwardRef(
    (
      {
        isDragging,
        styleOnDrag,
        connectDragSource,
        connectDropTarget,
        ...props
      },
      ref
    ) => {
      const elementRef = useRef(null);
      connectDragSource(elementRef);
      connectDropTarget(elementRef);
      useImperativeHandle(ref, () => ({
        getNode: () => elementRef.current,
      }));
      return (
        <div ref={elementRef} style={isDragging ? styleOnDrag : null}>
          <Component isDragging={isDragging} {...props} />
        </div>
      );
    }
  );
  Orderable.displayName = `Orderable(${Component.displayName ||
    Component.name ||
    'Component'})`;

  Orderable.propTypes = {
    isDragging: PropTypes.bool.isRequired,
    connectDragSource: PropTypes.func.isRequired,
    connectDropTarget: PropTypes.func.isRequired,
    styleOnDrag: PropTypes.object,
  };

  Orderable.defaultProps = {
    styleOnDrag: { opacity: 0.6 },
  };

  return getDropTarget(
    type,
    getIndex,
    getMoveFnc
  )(getDragSource(type, getIndex, getItem)(Orderable));
};
