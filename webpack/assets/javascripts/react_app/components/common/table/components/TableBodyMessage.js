import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';

const TableBodyMessage = ({ colSpan, children }) => (
  <tbody>
    <tr>
      <td colSpan={colSpan}>{children}</td>
    </tr>
  </tbody>
);

TableBodyMessage.propTypes = {
  colSpan: PropTypes.number.isRequired,
  children: PropTypes.node.isRequired,
};

export default TableBodyMessage;
