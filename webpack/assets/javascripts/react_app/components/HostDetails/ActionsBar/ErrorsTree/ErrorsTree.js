import React from 'react';
import { TableComposable, Tbody } from '@patternfly/react-table';
import PropTypes from 'prop-types';
import { ErrorsTreePrimaryRow } from './components/ErrorsTreePrimaryRow';
import { ErrorsTreeSecondaryRow } from './components/ErrorsTreeSecondaryRow';

export const ErrorsTree = props => {
  const [expandedNodeNames, setExpandedNodeNames] = React.useState([]);
  const [
    expandedDetailsNodeNames,
    setExpandedDetailsNodeNames,
  ] = React.useState([]);

  const renderPrimaryRows = (
    [node, ...remainingNodes],
    level = 1,
    posinset = 1,
    rowIndex = 0,
    isHidden = false
  ) => {
    if (!node) {
      return [];
    }
    const isExpanded = expandedNodeNames.includes(node.id);
    const isDetailsExpanded = expandedDetailsNodeNames.includes(node.id);

    const childRows =
      node.children && node.children.length
        ? renderSecondaryRows(
            node.children,
            level + 1,
            1,
            rowIndex + 1,
            !isExpanded || isHidden
          )
        : [];
    return [
      <ErrorsTreePrimaryRow
        posinset={posinset}
        key={node.id}
        node={node}
        isExpanded={isExpanded}
        isDetailsExpanded={isDetailsExpanded}
        setExpandedNodeNames={setExpandedNodeNames}
        setExpandedDetailsNodeNames={setExpandedDetailsNodeNames}
      />,

      ...childRows,
      ...renderPrimaryRows(
        remainingNodes,
        level,
        posinset + 1,
        rowIndex + 1 + childRows.length,
        isHidden
      ),
    ];
  };

  const renderSecondaryRows = (
    [node, ...remainingNodes],
    level,
    posinset,
    rowIndex,
    isHidden = false
  ) => {
    if (!node) {
      return [];
    }

    return [
      <ErrorsTreeSecondaryRow
        posinset={posinset}
        key={rowIndex}
        node={node}
        isHidden={isHidden}
      />,

      ...renderSecondaryRows(
        remainingNodes,
        level,
        posinset + 1,
        rowIndex + 1,
        isHidden
      ),
    ];
  };

  return (
    <TableComposable
      ouiaId="errorsTreeTable"
      isTreeTable
      aria-label="Tree table"
      variant="compact"
    >
      <Tbody>{renderPrimaryRows(props.data)}</Tbody>
    </TableComposable>
  );
};

ErrorsTree.propTypes = {
  data: PropTypes.array,
};

ErrorsTree.defaultProps = {
  data: [],
};
