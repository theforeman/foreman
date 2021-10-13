import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { selectGeneratingProps } from './TemplateGeneratorSelectors';
import reducer from './TemplateGeneratorReducer';
import * as templateActions from './TemplateGeneratorActions';
import TemplateGenerator from './TemplateGenerator';

export const actions = templateActions;

// export reducers
export const reducers = { templates: reducer };

// map state to props
const mapStateToProps = (state) => selectGeneratingProps(state);

// map action dispatchers to props
const mapDispatchToProps = (dispatch) => bindActionCreators(actions, dispatch);

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(TemplateGenerator);
