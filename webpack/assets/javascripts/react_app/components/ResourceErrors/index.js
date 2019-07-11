import { connect } from 'react-redux';

import ResourceErrors from './ResourceErrors';

import * as resourceErrorsActions from './ResourceErrorsActions';

import reducer from './ResourceErrorsReducer';

export const reducers = { resourceErrors: reducer };

export default connect(null, resourceErrorsActions)(ResourceErrors);
