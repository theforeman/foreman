import React from 'react';
import PropTypes from 'prop-types';
import { OverlayTrigger, Popover } from 'patternfly-react';
import classNames from 'classnames';
import './HostStatus.scss';

const HostStatus = ({ className, overviewFields }) => {
  const cx = classNames(className, 'clickable-host-status');
  const table = (
    <table id="properties_table">
      <tbody>
        {overviewFields.map(([name, value], key) => (
          <tr key={key}>
            <td className="property_name">{name}</td>
            <td
              className="property_value"
              dangerouslySetInnerHTML={{ __html: value }}
            />
          </tr>
        ))}
      </tbody>
    </table>
  );

  return (
    <OverlayTrigger
      rootClose
      trigger="click"
      placement="right"
      overlay={
        <Popover id="host-status-popover" title="Properties Overview">
          {table}
        </Popover>
      }
    >
      <span className={cx} />
    </OverlayTrigger>
  );
};

HostStatus.propTypes = {
  className: PropTypes.string.isRequired,
  overviewFields: PropTypes.array.isRequired,
};

export default HostStatus;
