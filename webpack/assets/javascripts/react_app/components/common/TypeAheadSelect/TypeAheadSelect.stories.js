import React from 'react';
import TypeAheadSelect from '.';
import Story from '../../../../../..//stories/components/Story';
import storeDecorator from '../../../../../..//stories/storeDecorator';

export default {
  title: 'Components/TypeAheadSelect',
  decorators: [storeDecorator],
  component: TypeAheadSelect,
};

export const defaultTypeAhead = () => (
  <Story>
    <TypeAheadSelect
      id="default_typeahead"
      options={['Bear', 'Walrus']}
      selected={['Walrus']}
    />
  </Story>
);

export const withPlaceholderText = () => (
  <Story>
    <TypeAheadSelect
      id="placeholder_typeahead"
      options={['Bear', 'Walrus']}
      placeholder="Inspirational placeholder"
    />
  </Story>
);

export const multipleSelections = () => (
  <Story>
    <TypeAheadSelect
      id="multiple_typeahead"
      options={['Bear', 'Walrus']}
      multiple
    />
  </Story>
);

export const freehandSelections = () => (
  <Story>
    <div>New options can be freely added that are not present in options</div>
    <TypeAheadSelect
      id="freehand_typeahead"
      options={['Bear', 'Walrus']}
      allowNew
    />
  </Story>
);

export const withClearButton = () => (
  <Story>
    <TypeAheadSelect
      id="clearbutton_typeahead"
      options={['Bear', 'Walrus']}
      selected={['Bear']}
      clearButton
    />
  </Story>
);
