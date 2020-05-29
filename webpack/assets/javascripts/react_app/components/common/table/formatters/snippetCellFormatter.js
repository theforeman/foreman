import React from 'react';
import SnippetCell from '../components/SnippetCell';

const snippetCellFormatter = () => (
  value
) => (
  <SnippetCell
    condition={value}
  />
);

export default snippetCellFormatter;
