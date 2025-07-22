import React from 'react';
import { Truncate } from '@patternfly/react-core';
import cellFormatter from './cellFormatter';

export default value => cellFormatter(<Truncate content={value || ''} />);
