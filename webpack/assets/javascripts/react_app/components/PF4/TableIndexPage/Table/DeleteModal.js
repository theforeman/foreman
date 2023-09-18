import React from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Button, Modal } from '@patternfly/react-core';

import { sprintf, translate as __ } from '../../../../common/I18n';
import { APIActions } from '../../../../redux/API';

export const DeleteModal = ({
  isModalOpen,
  setIsModalOpen,
  url,
  selectedItem,
  refreshData,
}) => {
  const { name, id } = selectedItem;
  const dispatch = useDispatch();
  const onSubmit = () => {
    dispatch(
      APIActions.delete({
        url: `${url}/${id}`,
        key: 'DELETE_MODAL',
        handleSuccess: () => {
          setIsModalOpen(false);
          refreshData();
        },
        successToast: () => sprintf(__('%s was successfully deleted'), name),
        errorToast: ({ message }) => message,
      })
    );
  };
  return (
    <Modal
      ouiaId="delete-modal"
      title={__('Confirm Deletion')}
      titleIconVariant="danger"
      variant="small"
      isOpen={isModalOpen}
      onClose={() => setIsModalOpen(false)}
      appendTo={() => document.getElementsByTagName('table')[0]}
      actions={[
        <Button
          key="confirm"
          onClick={onSubmit}
          variant="danger"
          ouiaId="confirm-delete"
        >
          {__('Delete')}
        </Button>,
        <Button
          key="cancel"
          variant="link"
          onClick={() => setIsModalOpen(false)}
          ouiaId="cancel-delete"
        >
          {__('Cancel')}
        </Button>,
      ]}
    >
      {sprintf(__('You are about to delete %s. Are you sure?'), name)}
    </Modal>
  );
};

DeleteModal.propTypes = {
  isModalOpen: PropTypes.bool.isRequired,
  setIsModalOpen: PropTypes.func.isRequired,
  url: PropTypes.string.isRequired,
  selectedItem: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
  }),
  refreshData: PropTypes.func.isRequired,
};

DeleteModal.defaultProps = {
  selectedItem: {},
};
