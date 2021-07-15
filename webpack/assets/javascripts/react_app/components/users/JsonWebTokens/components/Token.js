import React from 'react';
import PropTypes from 'prop-types';

import ClipboardCopy from '../../../common/ClipboardCopy';
import SkeletonLoader from '../../../common/SkeletonLoader';
import { translate as __ } from '../../../../common/I18n';

const Token = ({ status, token }) => (
  <SkeletonLoader status={status} emptyState="">
    <div className="text-center">
      <pre>{token}</pre>
      <ClipboardCopy
        text={token}
        buttonText={__('Copy token to clipboard')}
        textareaProps={{
          hidden: true,
        }}
        buttonProps={{ className: 'center-block' }}
      />
    </div>
  </SkeletonLoader>
);

Token.propTypes = {
  status: PropTypes.string,
  token: PropTypes.string,
};

Token.defaultProps = {
  status: '',
  token: '',
};

export default Token;
