import React from 'react';
import PropTypes from 'prop-types';
import { Alert } from 'patternfly-react';

import { translate as __ } from '../../common/I18n';

const Log = ({ output, timestamp, outdated }) => (
  <>
    {outdated &&
      <Alert className="base in fade" type="info">
        {__('Console output may be out of date')}
      </Alert>}
    <pre className="pre-scrollable">
      <code>
        {output}
      </code>
    </pre>
  </>
);

Log.propTypes = {
  output: PropTypes.string.isRequired,
  timestamp: PropTypes.oneOfType([PropTypes.instanceOf(Date), PropTypes.string]),
  outdated: PropTypes.bool,
};

Log.defaultProps = {
  outdated: false,
  timestamp: undefined
};

export default Log;
