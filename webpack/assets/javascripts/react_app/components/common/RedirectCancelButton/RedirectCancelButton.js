import React, { useEffect } from 'react';
import { Button } from 'patternfly-react';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';

import withReactRoutes from '../../../common/withReactRoutes';
import { translate as __ } from '../../../common/I18n';
import { deprecate } from '../../../common/DeprecationService';

const RedirectCancelButton = props => {
  useEffect(() => {
    deprecate(
      'common/RedirectCancelButton',
      'Button from @patternfly/react-core',
      '3.21'
    );
  }, []);

  return (
    <Link to={props.cancelPath}>
      <Button>{__('Cancel')}</Button>
    </Link>
  );
};

RedirectCancelButton.propTypes = {
  cancelPath: PropTypes.string,
};

RedirectCancelButton.defaultProps = {
  cancelPath: undefined,
};

export default withReactRoutes(RedirectCancelButton);
