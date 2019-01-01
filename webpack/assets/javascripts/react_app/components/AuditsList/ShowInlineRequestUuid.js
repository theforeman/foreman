import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col } from 'patternfly-react';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import { translate as __ } from '../../common/I18n';

const ShowInlineRequestUuid = ({ fetchAndPush, requestUuid, id }) => (
  <Col sm={10} className="request-uuid-column">
    <Row>
      <Col md={2}>
        <span>{__('Request UUID')}</span>
      </Col>
      <Col md={10} className="value">
        <EllipsisWithTooltip>
          <a
            onClick={() =>
              fetchAndPush({ searchQuery: `request_uuid = ${requestUuid}` })
            }
            title={__(
              'HTTP request UUID, clicking will filter audits for this request. It can also be used for searching in application logs.'
            )}
          >
            {requestUuid}
          </a>
        </EllipsisWithTooltip>
      </Col>
    </Row>
  </Col>
);

ShowInlineRequestUuid.propTypes = {
  fetchAndPush: PropTypes.func.isRequired,
  requestUuid: PropTypes.string.isRequired,
  id: PropTypes.number.isRequired,
};

export default ShowInlineRequestUuid;
