import React from 'react';
import Table from '../../common/table';
import { columns } from './schema';
import { plugin } from '../../../common/EmptyStates';

const AboutPluginTable = props => (
  <Table
    rows={props.data}
    columns={columns()}
    emptyState={plugin()}
  />
);

export default AboutPluginTable;
