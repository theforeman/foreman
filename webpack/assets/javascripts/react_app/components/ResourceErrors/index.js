import { useEffect } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';

import { resolveResourceErrors } from './ResourceErrorsActions';

import reducer from './ResourceErrorsReducer';

export const reducers = { resourceErrors: reducer };

const ResourceErrors = ({ resourceErrors }) => {
  const dispatch = useDispatch();
  const dispatchResolveResourceErrors = () =>
    dispatch(resolveResourceErrors(resourceErrors));

  useEffect(() => {
    dispatchResolveResourceErrors();
  }, [dispatch]);

  return null;
};

ResourceErrors.propTypes = {
  resourceErrors: PropTypes.object,
};

ResourceErrors.defaultProps = {
  resourceErrors: {},
};

export default ResourceErrors;
