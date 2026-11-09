import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { deprecate } from '../../../../common/DeprecationService';

const HostsCountCell = ({ name, controller, children }) => {
  useEffect(() => {
    deprecate(
      'table/components/HostsCountCell',
      'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
      '5.2'
    );
  }, []);

  return (
    <a href={`hosts?search=${controller}+%3D+"${encodeURI(name)}"`}>
      {children}
    </a>
  );
};

HostsCountCell.propTypes = {
  name: PropTypes.string.isRequired,
  controller: PropTypes.string.isRequired,
  children: PropTypes.node.isRequired,
};

HostsCountCell.defaultProps = {};

export default HostsCountCell;
