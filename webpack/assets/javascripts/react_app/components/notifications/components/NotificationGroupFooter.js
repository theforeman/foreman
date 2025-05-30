import React from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';

import { Button, Flex, FlexItem } from '@patternfly/react-core';
import {
  clearGroup,
  markGroupAsRead,
} from '../../../redux/actions/notifications';
import { translate as __ } from '../../../common/I18n';

const NotificationGroupFooter = ({ groupName, unread }) => {
  const dispatch = useDispatch();
  return (
    <Flex justifyContent={{ default: 'justifyContentCenter' }}>
      <FlexItem>
        <Button
          ouiaId={`clear-group-btn-${groupName}`}
          variant="link"
          onClick={() => dispatch(clearGroup(groupName))}
        >
          {__('Clear group')}
        </Button>
      </FlexItem>
      {unread !== 0 && (
        <FlexItem>
          <Button
            ouiaId={`read-group-btn-${groupName}`}
            variant="link"
            onClick={() => dispatch(markGroupAsRead(groupName))}
          >
            {__('Mark group as read')}
          </Button>
        </FlexItem>
      )}
    </Flex>
  );
};

NotificationGroupFooter.propTypes = {
  groupName: PropTypes.string.isRequired,
  unread: PropTypes.number.isRequired,
};

export default NotificationGroupFooter;
