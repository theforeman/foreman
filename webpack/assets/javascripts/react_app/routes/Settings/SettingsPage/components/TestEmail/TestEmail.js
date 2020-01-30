import React from 'react';
import PropTypes from 'prop-types';

import { Button, Spinner, Row, Col } from 'patternfly-react';

const TestEmail = ({ loading, testEmail }) => (
  <Row className="test-email-row">
    <Col md={12}>
      <div className="btn-toolbar pull-right">
        <div id="toolbar-spinner">
          <Spinner loading={loading} size="sm" />
        </div>
        <Button bsStyle="success" onClick={testEmail} disabled={loading}>
          Test Email
        </Button>
      </div>
    </Col>
  </Row>
);

TestEmail.propTypes = {
  loading: PropTypes.bool.isRequired,
  testEmail: PropTypes.func.isRequired,
};

export default TestEmail;
