import React from 'react';
import Table from '../../common/table';
import { columns } from './schema';
import { smartProxy } from '../../../common/EmptyStates';

const AboutProxyTable = props => (
  <Table
    emptyState={smartProxy()}
    rows={props.data}
    columns={columns()}
    />
);

export default AboutProxyTable;
