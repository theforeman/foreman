import React from 'react';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import cellFormatter from './cellFormatter';

export default (value) =>
  cellFormatter(<EllipsisWithTooltip>{value || ''}</EllipsisWithTooltip>);
