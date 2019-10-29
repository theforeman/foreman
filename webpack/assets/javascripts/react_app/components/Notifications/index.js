import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as NotificationActions from './NotificationsActions';
import reducer from './NotificationsReducer';
import { APIActions } from '../../redux/API';
import {
  selectIsDrawerOpen,
  selectNotifications,
  selectExpandedGroup,
  selectIsReady,
  selectHasUnreadMessages,
} from './NotificationsSelectors';
import Notifications from './Notifications';

// map state to props
const mapStateToProps = state => ({
  isDrawerOpen: selectIsDrawerOpen(state),
  notifications: selectNotifications(state),
  expandedGroup: selectExpandedGroup(state),
  isReady: selectIsReady(state),
  hasUnreadMessages: selectHasUnreadMessages(state),
});

// map action dispatchers to props
const mapDispatchToProps = dispatch =>
  bindActionCreators({ ...NotificationActions, ...APIActions }, dispatch);

// export reducers
export const reducers = { notifications: reducer };

// export connected component
export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Notifications);
