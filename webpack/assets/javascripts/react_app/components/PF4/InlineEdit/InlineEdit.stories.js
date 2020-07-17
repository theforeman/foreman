import React, { useState, createElement } from 'react';
import { text, boolean } from '@storybook/addon-knobs';
import Story from '../../../../../../stories/components/Story';
import InlineEdit from './InlineEdit';

export default {
  title: 'Components/PF4/InlineEdit',
};

// Wrapping in createElement so the hooks work properly
// see https://github.com/storybookjs/storybook/issues/5721#issuecomment-472769646
export const defaultStory = () => createElement(() => {
  const [value, setValue] = useState('hello');
  const [value2, setValue2] = useState('hello again');

  const onSave = async (v, a) => {
    // delay to emulate an asynchronous backend call
    await (async () => new Promise(resolve => setTimeout(resolve, 1000)))();
    setValue(v);
    alert(`Update of ${a} successful`);
  };

  const onSave2 = async (v, a) => {
    // delay to emulate an asynchronous backend call
    await (async () => new Promise(resolve => setTimeout(resolve, 1000)))();
    setValue2(v);
    alert(`Update of ${a} successful`);
  };

  return (
    <Story>
      <InlineEdit
        value={value}
        attribute="backend_identifier"
        onSave={onSave}
      />
      <InlineEdit
        value={value2}
        attribute="backend_identifier2"
        onSave={onSave2}
      />
    </Story>
  );
});

export const withTextArea = () => createElement(() => {
  const [value, setValue] = useState('Text area: Pressing enter will not submit');

  return (
    <Story>
      <InlineEdit
        value={text('value', value)}
        attribute="backend_identifier"
        textArea={boolean('text area', true)}
        onSave={v => setValue(v)}
      />
    </Story>
  );
});

export const nothingProvided = () => createElement(() => {
  const [value, setValue] = useState(null);

  return (
    <Story>
      <InlineEdit
        value={value}
        attribute="backend_identifier"
        textArea
        onSave={v => setValue(v)}
      />
    </Story>
  );
});

defaultStory.story = {
  name: 'With backend call',
};
