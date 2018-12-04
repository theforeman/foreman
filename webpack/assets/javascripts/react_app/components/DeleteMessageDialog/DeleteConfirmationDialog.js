import React from 'react';
import PropTypes from 'prop-types';
import { MessageDialog, Icon, Button, Spinner } from 'patternfly-react';
import { sprintf, translate as __ } from '../../common/I18n';
import { noop } from '../../common/helpers';
import './deleteConfirmationDialog.scss';

const DeleteConfirmationDialog = ({
  url,
  name,
  show,
  processing,
  deleteItem,
  closeDialog,
  dialogTitle,
  cancelText,
  dialogContent,
}) => (
  <MessageDialog
    show={show}
    onHide={closeDialog}
    footer={
      <React.Fragment>
        <Button bsStyle="default" onClick={closeDialog} disabled={processing}>
          {cancelText}
        </Button>
        <Button
          bsStyle="danger"
          disabled={processing}
          onClick={() => deleteItem()}
          href={url}
          // TODO(bshuster): Use API to avoid full page refresh.
          data-method="delete"
        >
          <Spinner loading={processing} inline size="xs" />
          {sprintf('Delete %s', name)}
        </Button>
      </React.Fragment>
    }
    title={dialogTitle}
    primaryContent={
      <span className="lead">
        {sprintf('Are you sure you want to delete %s?', name)}
      </span>
    }
    secondaryContent={dialogContent}
    icon={<Icon id="delete-modal-icon" type="pf" name="error-circle-o" />}
  />
);

DeleteConfirmationDialog.propTypes = {
  name: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
  show: PropTypes.bool,
  processing: PropTypes.bool,
  deleteItem: PropTypes.func,
  closeDialog: PropTypes.func,
  dialogContent: PropTypes.node,
  dialogTitle: PropTypes.string,
  cancelText: PropTypes.string,
};

DeleteConfirmationDialog.defaultProps = {
  show: false,
  processing: false,
  deleteItem: noop,
  closeDialog: noop,
  dialogTitle: __('Confirmation Dialog'),
  dialogContent: (
    <div>
      {__(
        `This action is irreversible. If you are not sure what you are doing, click on Cancel.`
      )}
    </div>
  ),
  cancelText: __('Cancel'),
};

export default DeleteConfirmationDialog;
