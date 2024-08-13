import React from 'react';
import { Td, TreeRowWrapper } from '@patternfly/react-table';
import PropTypes from 'prop-types';
import { ErrorPresenter } from './ErrorPresenter';

export const ErrorsTreeSecondaryRow = props => {
  const { isHidden } = props;

  const treeRow = {
    props: {
      isHidden,
      'aria-level': 2,
      'aria-posinset': props.posinset,
      'aria-setsize': 0,
    },
  };

  return (
    <TreeRowWrapper
      row={{
        props: treeRow.props,
      }}
    >
      <Td dataLabel="Variable" treeRow={treeRow}>
        <ErrorPresenter errorMessage={props.node?.name} />
      </Td>
    </TreeRowWrapper>
  );
};

ErrorsTreeSecondaryRow.propTypes = {
  posinset: PropTypes.number,
  isHidden: PropTypes.bool,
  node: PropTypes.object,
};

ErrorsTreeSecondaryRow.defaultProps = {
  posinset: 0,
  isHidden: false,
  node: {},
};
