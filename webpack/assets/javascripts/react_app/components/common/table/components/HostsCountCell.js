import React from 'react';
import PropTypes from 'prop-types';

const HostsCountCell = ({ name, controller, children }) => (
  <a href={`hosts?search=${controller}+%3D+"${encodeURI(name)}"`}>{children}</a>
);

HostsCountCell.propTypes = {
  name: PropTypes.string.isRequired,
  controller: PropTypes.string.isRequired,
  children: PropTypes.node.isRequired,
};

HostsCountCell.defaultProps = {};

export default HostsCountCell;
