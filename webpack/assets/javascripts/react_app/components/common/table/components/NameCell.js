import React from 'react';
import PropTypes from 'prop-types';

const NameCell = ({ active, id, name, controller, children }) =>
  active ? (
    <a href={`/${controller}/${id}-${name}/edit`}>{children}</a>
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
  children: PropTypes.node.isRequired,
};

NameCell.defaultProps = {
  active: false,
};

export default NameCell;
