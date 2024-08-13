import React from 'react';
import { Td, TreeRowWrapper } from '@patternfly/react-table';
import { Badge } from '@patternfly/react-core';
import PropTypes from 'prop-types';

export const ErrorsTreePrimaryRow = props => {
  const { isExpanded } = props;
  const { isDetailsExpanded } = props;

  const treeRow = {
    onCollapse: () =>
      props.setExpandedNodeNames(prevExpanded => {
        const otherExpandedNodeNames = prevExpanded.filter(
          name => name !== props.node.id
        );
        return props.isExpanded
          ? otherExpandedNodeNames
          : [...otherExpandedNodeNames, props.node.id];
      }),
    onToggleRowDetails: () =>
      props.setExpandedDetailsNodeNames(prevDetailsExpanded => {
        const otherDetailsExpandedNodeNames = prevDetailsExpanded.filter(
          name => name !== props.node.id
        );
        return isDetailsExpanded
          ? otherDetailsExpandedNodeNames
          : [...otherDetailsExpandedNodeNames, props.node.id];
      }),
    props: {
      isExpanded,
      isDetailsExpanded,
      'aria-level': 1,
      'aria-posinset': props.posinset,
      'aria-setsize': props.node.children ? props.node.children.length : 0,
    },
  };

  return (
    <TreeRowWrapper
      row={{
        props: treeRow.props,
      }}
    >
      <Td treeRow={treeRow}>
        <>
          {props.node.name}{' '}
          <Badge key={`${props.node.name}_badge`} isRead>
            {props.node.children.length}
          </Badge>
        </>
      </Td>
    </TreeRowWrapper>
  );
};

ErrorsTreePrimaryRow.propTypes = {
  posinset: PropTypes.number,
  isExpanded: PropTypes.bool,
  isDetailsExpanded: PropTypes.bool,
  setExpandedNodeNames: PropTypes.func,
  setExpandedDetailsNodeNames: PropTypes.func,
  node: PropTypes.object,
};

ErrorsTreePrimaryRow.defaultProps = {
  posinset: 0,
  isExpanded: false,
  isDetailsExpanded: false,
  setExpandedNodeNames: () => {},
  setExpandedDetailsNodeNames: () => {},
  node: {},
};
