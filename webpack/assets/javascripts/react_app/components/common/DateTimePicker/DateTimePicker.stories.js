import React from 'react';
import { storiesOf } from '@storybook/react';
import DateTimePicker from './DateTimePicker';
import Story from '../../../../../../stories/components/Story';

storiesOf('Components/DateTimePicker', module).add('DateTimePicker', () => (
  <Story>
    <div>
      <br />
      <br />
      <br />
      <br />
      <br />
      <br />
      <br />
      <br />
      <br />
      <br />
      <br />
      <br />
      <label>Date Time picker</label>
      <div className="row">
        <div className="col-md-5">
          <DateTimePicker />
        </div>
      </div>
    </div>
  </Story>
));
