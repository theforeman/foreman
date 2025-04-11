import React from 'react';
import PropTypes from 'prop-types';
import { GridItem, Button, Tooltip } from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';

const ShowInlineRequestUuid = ({ fetchAndPush, requestUuid, id }) => (
  <React.Fragment>
    <GridItem span={3}>
      <span>{__('Request UUID')}</span>
    </GridItem>
    <GridItem span={9} className="value">
      <Tooltip
        content={__(
          'HTTP request UUID, clicking will filter audits for this request. It can also be used for searching in application logs.'
        )}
      >
        <Button
          ouiaId="request-uuid-btn"
          variant="link"
          isInline
          onClick={() =>
            fetchAndPush({ searchQuery: `request_uuid = ${requestUuid}` })
          }
        >
          {requestUuid}
        </Button>
      </Tooltip>
    </GridItem>
  </React.Fragment>
);

ShowInlineRequestUuid.propTypes = {
  fetchAndPush: PropTypes.func.isRequired,
  requestUuid: PropTypes.string.isRequired,
  id: PropTypes.number.isRequired,
};

export default ShowInlineRequestUuid;
