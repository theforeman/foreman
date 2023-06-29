import React from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Td, ActionsColumn } from '@patternfly/react-table';
import { APIActions } from '../../../../redux/API';
import { sprintf, translate as __ } from '../../../../common/I18n';
import { HOST_PARAM } from './ParametersConstants';
import { openConfirmModal } from '../../../ConfirmModal';
import { updateHost } from '../../ActionsBar/actions';

export const RowActions = ({ hostId, param, editHostsPermission }) => {
  const dispatch = useDispatch();
  const onDelete = () =>
    dispatch(
      APIActions.delete({
        url: `/api/hosts/${hostId}/parameters/${param.id}`,
        key: `${param.id}-DELETE`,
        successToast: () => sprintf(__('Parameter %s deleted'), param.name),

        errorToast: ({ response }) =>
          // eslint-disable-next-line camelcase
          response?.data?.error?.full_messages ||
          response?.data?.error?.message,
        handleSuccess: () => {
          dispatch(updateHost(hostId));
        },
      })
    );
  const rowActions = [
    editHostsPermission &&
      param.associated_type === HOST_PARAM && {
        title: __('Delete'),
        onClick: () => {
          dispatch(
            openConfirmModal({
              title: sprintf(__('Delete %s'), param.name),
              message: __(
                'This will change the delete the parameter, are you sure?'
              ),
              isWarning: true,
              onConfirm: () => {
                onDelete();
              },
            })
          );
        },
      },
  ].filter(a => a);
  return (
    <Td isActionCell className="parameters-actions">
      {!!rowActions.length && <ActionsColumn items={rowActions} />}
    </Td>
  );
};

RowActions.propTypes = {
  param: PropTypes.shape({
    name: PropTypes.string,
    parameter_type: PropTypes.string,
    value: PropTypes.any,
    id: PropTypes.number,
    'hidden_value?': PropTypes.bool,
    override: PropTypes.bool,
    associated_type: PropTypes.string,
  }).isRequired,
  hostId: PropTypes.number.isRequired,
  editHostsPermission: PropTypes.bool.isRequired,
};
