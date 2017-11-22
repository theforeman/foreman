import React from 'react';
import Table from '../../common/table';
import { columns } from './schema';
import { computeResource } from '../../../common/EmptyStates';

const AboutProviderTable = props => (
    <Table
      rows={props.data}
      emptyState={computeResource()}
      columns={columns()}
    />
);
export default AboutProviderTable;
