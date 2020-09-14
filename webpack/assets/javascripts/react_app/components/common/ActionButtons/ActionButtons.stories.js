import React from 'react';
import { ActionButtons } from './ActionButtons';
import Story from '../../../../../../stories/components/Story';
import Text from '../../../../../../stories/components/Text';

import { buttons } from './ActionButtons.fixtures';

export default {
  title: 'Components/Common/ActionButtons',
};

export const ButtonsStory = () => (
  <Story>
    <Text>
      <u>Input</u>: an array of button props each containing: a title string and
      an action object. <br />
      action can be <strong> href</strong> with <strong>data-method</strong> or
      <strong> onClick</strong>
      <br />
      <u>Output</u>: a button or drop down of buttons
      <br />
      <br />
    </Text>
    <Text>No buttons</Text>
    <ActionButtons buttons={[]} />
    <br />
    <Text>One button</Text>
    <ActionButtons buttons={[buttons[0]]} />
    <br />
    <Text>Three buttons</Text>
    <ActionButtons buttons={buttons} />
  </Story>
);

ButtonsStory.story = {
  name: 'ActionButtons',
};
