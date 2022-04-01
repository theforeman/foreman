import React from 'react';
import { Icon } from 'patternfly-react';
import { Tooltip, TooltipPosition } from '@patternfly/react-core';
import PropTypes from 'prop-types';

const InstanceTitleViewer = ({ title }) => {
  if (!title) {
    return null;
  }

  return (
    <Tooltip
      position={TooltipPosition.bottom}
      id="instance-toggle-icon"
      content={title}
    >
      <Icon type="fa" name="server small" />
    </Tooltip>
  );
};

InstanceTitleViewer.propTypes = {
  /** Title to display */
  title: PropTypes.string,
};
InstanceTitleViewer.defaultProps = {
  title: '',
};
export default InstanceTitleViewer;
