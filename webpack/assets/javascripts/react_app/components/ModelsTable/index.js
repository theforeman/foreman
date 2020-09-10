import React from 'react';
import PropTypes from 'prop-types';

import ModelsTable from './ModelsTable';
import { MODEL_DELETE_MODAL_ID } from '../../routes/Models/constants';
import { useForemanModal } from '../ForemanModal/ForemanModalHooks';

const WrappedModelsTable = props => {
  const { setModalOpen } = useForemanModal({ id: MODEL_DELETE_MODAL_ID });
  const { setToDelete, ...rest } = props;

  const onDeleteClick = rowData => {
    setToDelete(rowData);
    setModalOpen();
  };

  return <ModelsTable {...rest} onDeleteClick={onDeleteClick} />;
};

WrappedModelsTable.propTypes = {
  setToDelete: PropTypes.func.isRequired,
};

export default WrappedModelsTable;
