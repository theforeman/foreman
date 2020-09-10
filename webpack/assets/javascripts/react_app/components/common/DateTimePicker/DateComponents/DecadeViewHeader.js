import React from 'react';
import PropTypes from 'prop-types';
import { noop } from '../../../../common/helpers';

export const DecadeViewHeader = ({
  currDecade,
  getPrevDecade,
  getNextDecade,
}) => (
  <thead>
    <tr>
      <th className="prev" onClick={getPrevDecade}>
        <span className="glyphicon glyphicon-chevron-left" />
      </th>
      <th className="picker-switch" data-action="pickerSwitch" colSpan="5">
        {`${currDecade}-${currDecade + 11}`}
      </th>
      <th className="next" onClick={getNextDecade}>
        <span className="glyphicon glyphicon-chevron-right" />
      </th>
    </tr>
  </thead>
);

DecadeViewHeader.propTypes = {
  currDecade: PropTypes.number,
  getPrevDecade: PropTypes.func,
  getNextDecade: PropTypes.func,
};
DecadeViewHeader.defaultProps = {
  currDecade: 20,
  getPrevDecade: noop,
  getNextDecade: noop,
};
export default DecadeViewHeader;
