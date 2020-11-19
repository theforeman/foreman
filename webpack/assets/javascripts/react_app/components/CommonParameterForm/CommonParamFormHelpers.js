import React from 'react';
import { Button, Icon } from 'patternfly-react';

import StringValue from './components/values/StringValue';
import NumberValue from './components/values/NumberValue';
import BooleanValue from './components/values/BooleanValue';
import Editor from './components/values/Editor';

export const fieldSizeByType = type => {
  switch (type) {
    case 'integer':
    case 'real':
    case 'boolean':
      return 'col-md-4';
    default:
      return 'col-md-8';
  }
};

export const valueFieldByType = (type, fieldProps) => {
  switch (type) {
    case 'integer':
    case 'real':
      return <NumberValue {...fieldProps} />;
    case 'boolean':
      return <BooleanValue {...fieldProps} />;
    case 'array':
    case 'hash':
    case 'json':
      return <Editor {...fieldProps} mode="ruby" />;
    case 'yaml':
      return <Editor {...fieldProps} mode="text" />;
    default:
      return <StringValue {...fieldProps} />;
  }
};

export const showFullScreenBtn = (type, onClick) => {
  switch (type) {
    case 'string':
    case 'array':
    case 'hash':
    case 'json':
    case 'yaml':
      return (
        <Button bsStyle="default" onClick={() => onClick(true)}>
          <Icon name="expand" /> Full screen
        </Button>
      );
    default:
      return <></>;
  }
};

export const formPayload = (name, type, value, isMasked) => ({
  common_parameter: {
    name,
    parameter_type: type,
    value,
    hidden_value: isMasked,
  },
});
