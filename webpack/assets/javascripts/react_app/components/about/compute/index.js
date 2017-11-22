import React from 'react';
import Table from '../../common/table';
import { columns } from './schema';
import { computeResource } from '../../../common/EmptyStates';

const AboutComputeTable = props => (
  <Table
    emptyState={computeResource()}
    rows={props.data}
    columns={columns} />
);

export default AboutComputeTable;
