import React, { useEffect } from 'react';
import {
  Modal,
  ModalVariant,
  Button,
  Title,
  TitleSizes,
} from '@patternfly/react-core';
import { Table, TableHeader, TableBody } from '@patternfly/react-table';
import WarningTriangleIcon from '@patternfly/react-icons/dist/js/icons/warning-triangle-icon';

const StatusModal = ({ isOpen, onClose, closePopover }) => {
  useEffect(() => {
    isOpen && closePopover(false);
  }, [isOpen, closePopover]);
  const header = (
    <React.Fragment>
      <Title
        id="custom-header-label"
        headingLevel="h1"
        size={TitleSizes['2xl']}
      >
        Host Statuses
      </Title>
      <p className="pf-u-pt-sm">List of all the available host sub-statuses</p>
    </React.Fragment>
  );
  const columns = ['Name', 'Status'];
  const rows = [
    ['Build', 'Out of sync'],
    ['Configuration', 'Installed'],
    ['Execution', 'OK'],
    ['Errata', 'Up to date'],
    ['Subscription', 'Up to date'],
  ];
  const actions = () => [
    {
      title: 'Clear',
      onClick: (event, rowId, rowData, extra) =>
        console.log('clicked on Some action, on row: ', rowId),
    },
    {
      title: <a href="https://www.patternfly.org">Details</a>,
    },
  ];
  const table = (
    <Table
      aria-label="Simple Table"
      variant="compact"
      borders="compactBorderless"
      cells={columns}
      rows={rows}
      actions={actions()}
    >
      <TableHeader />
      <TableBody />
    </Table>
  );
  const footer = (
    <Title headingLevel="h4" size={TitleSizes.md}>
      <WarningTriangleIcon />
      <span className="pf-u-pl-sm">Custom modal footer.</span>
    </Title>
  );

  return (
    <Modal
      variant={ModalVariant.small}
      isOpen={isOpen}
      aria-label="My dialog"
      aria-labelledby="custom-header-label"
      aria-describedby="custom-header-description"
      header={header}
      onClose={onClose}
      on
      appendTo={document.body}
    >
      <br />
      {table}
    </Modal>
  );
};

export default StatusModal;
