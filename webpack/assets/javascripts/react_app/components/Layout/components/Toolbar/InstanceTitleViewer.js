import React from 'react';
import { Icon, OverlayTrigger, Tooltip } from 'patternfly-react';
import PropTypes from 'prop-types';

const InstanceTitleViewer = ({ title }) => {
  if (!title) {
    return null;
  }

  const tooltip = <Tooltip id="tooltip">{title}</Tooltip>;

  return (
    <OverlayTrigger
      placement="bottom"
      id="instance-toggle-icon"
      overlay={tooltip}
    >
      <Icon type="fa" name="server small" />
    </OverlayTrigger>
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
