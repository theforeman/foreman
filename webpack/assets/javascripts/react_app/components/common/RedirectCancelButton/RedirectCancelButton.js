import React from 'react';
import { Button } from 'patternfly-react';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';

import withReactRoutes from '../../../common/withReactRoutes';
import { translate as __ } from '../../../common/I18n';

const RedirectCancelButton = (props) => (
  <Link to={props.cancelPath}>
    <Button>{__('Cancel')}</Button>
  </Link>
);

RedirectCancelButton.propTypes = {
  cancelPath: PropTypes.string,
};

RedirectCancelButton.defaultProps = {
  cancelPath: undefined,
};

export default withReactRoutes(RedirectCancelButton);
