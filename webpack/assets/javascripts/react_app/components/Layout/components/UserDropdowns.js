import React from 'react';
import PropTypes from 'prop-types';
import { get } from 'lodash';
import { Icon } from 'patternfly-react';
import {
  Dropdown,
  DropdownToggle,
  DropdownItem,
  DropdownSeparator,
} from '@patternfly/react-core';

import { translate as __ } from '../../../common/I18n';

class UserDropdowns extends React.Component {
  constructor(props) {
    super(props);
    this.state = { userDropdownOpen: false };
    this.onDropdownToggle = userDropdownOpen => {
      this.setState({
        userDropdownOpen,
      });
    };
    this.onDropdownSelect = event => {
      this.setState({
        userDropdownOpen: !this.state.userDropdownOpen,
      });
    };
  }

  render() {
    const {
      activeKey, // eslint-disable-line react/prop-types
      activeHref, // eslint-disable-line react/prop-types
      user,
      changeActiveMenu,
      notificationUrl,
      stopImpersonationUrl,
      ...props
    } = this.props;

    const { userDropdownOpen } = this.state;

    const userInfo = get(user, 'current_user.user');

    const userDropdownItems = user.user_dropdown[0].children.map((item, i) =>
      item.type === 'divider' ? (
        <DropdownSeparator key={i} />
      ) : (
        <DropdownItem
          key={i}
          href={item.url}
          onClick={() => {
            changeActiveMenu({ title: 'User' });
          }}
          className="user_menuitem"
          {...item.html_options}
        >
          {__(item.name)}
        </DropdownItem>
      )
    );

    return (
      <React.Fragment>
        {userInfo && (
          <Dropdown
            isPlain
            position="right"
            onSelect={this.onDropdownSelect}
            isOpen={userDropdownOpen}
            toggle={
              <DropdownToggle onToggle={this.onDropdownToggle}>
                <Icon type="fa" name="user avatar small" />
                {userInfo.name}
              </DropdownToggle>
            }
            dropdownItems={userDropdownItems}
            {...props}
          />
        )}
      </React.Fragment>
    );
  }
}

UserDropdowns.propTypes = {
  /** Additional element css classes */
  className: PropTypes.string,
  /** User Data Array */
  user: PropTypes.object,
  /** notification URL */
  notificationUrl: PropTypes.string,
  /** changeActiveMenu Func */
  changeActiveMenu: PropTypes.func,
  stopImpersonationUrl: PropTypes.string,
};
UserDropdowns.defaultProps = {
  className: '',
  user: {},
  notificationUrl: '',
  changeActiveMenu: null,
  stopImpersonationUrl: '',
};
export default UserDropdowns;
