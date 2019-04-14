import React from 'react';
import PropTypes from 'prop-types';
import { DualListControlled as PfDualList } from 'patternfly-react';
import { arrangeItemsBySelectedIDs } from './helpers';
import './dual-list.scss';

const DualList = ({ inputName, items, selectedIDs }) => {
  const { selectedList, unselectedlist } = arrangeItemsBySelectedIDs(
    items,
    selectedIDs
  );

  return (
    <PfDualList
      allowHiddenInputs
      left={{
        items: unselectedlist,
      }}
      right={{
        items: selectedList,
        inputProps: {
          name: inputName,
        },
      }}
    />
  );
};

DualList.propTypes = {
  inputName: PropTypes.string,
  items: PropTypes.arrayOf(
    PropTypes.shape({
      title: PropTypes.string,
      id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    })
  ),
  selectedIDs: PropTypes.arrayOf(
    PropTypes.oneOfType([PropTypes.string, PropTypes.number])
  ),
};

DualList.defaultProps = {
  inputName: '',
  items: [],
  selectedIDs: [],
};

export default DualList;
