import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';

const NameCell = ({ active, id, name, controller, children }) =>
  active ? (
    <Link to={`/${controller}/${id}-${name}/edit`}>{children}</Link>
  ) : (
    <a href="#" className="disabled" disabled="disabled" onClick={() => {}}>
      {children}
    </a>
  );

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
