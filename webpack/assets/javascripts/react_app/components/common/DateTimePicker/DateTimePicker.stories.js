import React from 'react';
import { Grid, Row, Col } from 'patternfly-react';
import DateTimePicker from './DateTimePicker';

export default {
  title: 'Components|DateTimePicker',
  component: DateTimePicker,
  parameters: {
    centered: { disable: true },
  },
};

export const useDateTimePicker = () => (
  <Grid fluid style={{ paddingTop: '300px' }}>
    <Row>
      <Col mdOffset={1} md={5}>
        <label>Date Time picker</label>
        <DateTimePicker />
      </Col>
    </Row>
  </Grid>
);
