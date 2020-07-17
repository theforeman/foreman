import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as settingActions from '../../Settings/SettingsActions';
import Search from './Search';

const mapStateToProps = state => ({});

const actions = { ...settingActions };

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export default connect(mapStateToProps, mapDispatchToProps)(Search);
