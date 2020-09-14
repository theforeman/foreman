import React from 'react';
import { Grid, Row, Col } from 'patternfly-react';
import DatePicker from './DatePicker';

export default {
  title: 'Components/DatePicker',
  component: DatePicker,
  parameters: {
    centered: { disable: true },
  },
};

export const useDatePicker = () => (
  <Grid fluid style={{ paddingTop: '300px' }}>
    <Row>
      <Col mdOffset={1} md={5}>
        <label>Date picker</label>
        <DatePicker />
      </Col>
    </Row>
  </Grid>
);
