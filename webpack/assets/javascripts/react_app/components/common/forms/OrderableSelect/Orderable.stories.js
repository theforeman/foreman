import React, { useState } from 'react';
import { DndProvider } from 'react-dnd';
import HTML5Backend from 'react-dnd-html5-backend';
import PropTypes from 'prop-types';

import Story from '../../../../../../../stories/components/Story';
import { orderable, orderDragged } from './helpers';
import { yesNoOpts } from '../__fixtures__/Form.fixtures';

const style = {
  border: '1px dashed gray',
  padding: '0.5rem 1rem',
  marginBottom: '.5rem',
  backgroundColor: 'white',
  cursor: 'move',
};
const StoryTag = ({ text, isDragging, value }) => {
  const opacity = isDragging ? 0.6 : 1;
  return (
    <span title={value} style={{ ...style, opacity }}>
      {text}
    </span>
  );
};
StoryTag.propTypes = {
  text: PropTypes.string.isRequired,
  isDragging: PropTypes.bool.isRequired,
  value: PropTypes.string.isRequired,
};

const OrderableStoryTag = orderable(StoryTag, {
  type: 'storyTag',
  getItem: props => ({ value: props.value }),
});

const OrderAppSandbox = props => {
  const [options, setOptions] = useState(props.options);

  const moveValue = (dragIndex, hoverIndex) => {
    setOptions(orderDragged(options, dragIndex, hoverIndex));
  };

  return (
    <div style={{ display: 'flex' }}>
      {options.map((opt, i) => (
        <OrderableStoryTag
          value={opt.value}
          key={opt.value}
          index={i}
          text={opt.label}
          moveValue={moveValue}
        />
      ))}
    </div>
  );
};
OrderAppSandbox.propTypes = {
  options: PropTypes.object.isRequired,
};

export default {
  title: 'Components|Common|Orderable',
};

export const orderableStory = () => (
  <Story>
    <DndProvider backend={HTML5Backend}>
      <OrderAppSandbox options={yesNoOpts} />
    </DndProvider>
  </Story>
);

orderableStory.story = {
  name: 'Orderable',
};
