import React from '@theforeman/vendor/react';
import EllipsisWithTooltip from '@theforeman/vendor/react-ellipsis-with-tooltip';
import cellFormatter from './cellFormatter';

export default value =>
  cellFormatter(<EllipsisWithTooltip>{value}</EllipsisWithTooltip>);
