import React from 'react';
import helpers from '../../common/helpers';
import NotificationPanel from './NotificationPanel';
import NotificationsStore from '../../stores/NotificationsStore';
import { ACTIONS } from '../../constants';

class NotificationAccordion extends React.Component {
  constructor(props) {
    super(props);
    helpers.bindMethods(this, ['onChange']);
    this.state = {expandedGroup: NotificationsStore.getExpandedGroup()};
  }

  componentDidMount() {
    NotificationsStore.addChangeListener(this.onChange);
  }

  onChange(actionType) {
    switch (actionType) {
      case ACTIONS.NOTIFICATIONS_EXPAND_DRAWER_TAB: {
        const expandedGroup = NotificationsStore.getExpandedGroup();

        this.setState({ expandedGroup: expandedGroup });
        break;
      }

      default:
        break;
    }
  }

  render() {
    const notifications = this.props.notifications;
    const keys = Object.keys(notifications);

    let markup = keys.map((key) => {
      return (
        <NotificationPanel key={key} title={key} id={key} expandedGroup={this.state.expandedGroup}
                           notifications={this.props.notifications[key]} />
      );
    });

    return (
      <div className="panel-group" id="notification-drawer-accordion">
        {markup}
      </div>
    );
  }
}

export default NotificationAccordion;
