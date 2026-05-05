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
  const ERROR_MESSAGE_PREFIX = __('Failed to delete: ');
  const parsedErrorMessage = (response, message) => {
    const errMsg =
      // eslint-disable-next-line camelcase
      response?.data?.error?.full_messages?.join(', ') ||
      response?.data?.error?.message ||
      message;
    return `${ERROR_MESSAGE_PREFIX} ${errMsg}`;
  };

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
        errorToast: ({ response, message }) =>
          parsedErrorMessage(response, message),
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
