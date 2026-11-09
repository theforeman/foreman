import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import { deprecate } from '../../../../common/DeprecationService';

const NameCell = ({ active, id, name, controller, children }) => {
  useEffect(() => {
    deprecate(
      'table/components/NameCell',
      'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
      '5.2'
    );
  }, []);

  if (active) {
    return <Link to={`/${controller}/${id}-${name}/edit`}>{children}</Link>;
  }

  return (
    <a href="#" className="disabled" disabled="disabled" onClick={() => {}}>
      {children}
    </a>
  );
};

NameCell.propTypes = {
  active: PropTypes.bool,
  id: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  controller: PropTypes.string.isRequired,
  children: PropTypes.node,
};

NameCell.defaultProps = {
  active: false,
  children: null,
};

export default NameCell;
