import React, { useState } from 'react';
import { storiesOf } from '@storybook/react';
import { Row } from 'patternfly-react';

import Story from '../../../../../../stories/components/Story';
import NumericInput from './NumericInput';

const NumericInputStory = props => {
  const [value, setValue] = useState([5, '5', '5 Gb']);

  return (
    <div className="container">
      <Row>
        <NumericInput
          value={value[0]}
          label="NumericInput"
          name="numeric"
          onValueChange={(valueAsNumber, valueAsString, input) =>
            setValue([valueAsNumber, valueAsString, input.value])
          }
          format={v => `${v} GB`}
        />
      </Row>
      <Row>
        <div className="col-md-12">
          {`valueAsNumber: ${value[0]},
            valueAsString: ${value[1]},
            input.value: ${value[2]}`}
        </div>
      </Row>
    </div>
  );
};

storiesOf('Components/FormInputs', module).add('Numeric Input', () => (
  <Story>
    <NumericInputStory />
  </Story>
));
