import React from 'react';
import { Icon, OverlayTrigger, Tooltip } from 'patternfly-react';
import PropTypes from 'prop-types';
import NavItem from './NavItem';

const InstanceTitleViewer = ({ title }) => {
  if (!title) {
    return null;
  }

  const tooltip = <Tooltip id="tooltip">{title}</Tooltip>;

  return (
    <NavItem className="nav-item-iconic">
      <OverlayTrigger
        placement="bottom"
        id="notifications-toggle-icon"
        overlay={tooltip}
      >
        <Icon type="fa" name="server small" />
      </OverlayTrigger>
    </NavItem>
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
