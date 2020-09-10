import { connect } from 'react-redux';
import * as ToastActions from '../../redux/actions/toasts';
import ToastsList from './ToastList';

const mapStateToProps = state => ({
  messages: state.toasts.messages,
});

export default connect(mapStateToProps, ToastActions)(ToastsList);
