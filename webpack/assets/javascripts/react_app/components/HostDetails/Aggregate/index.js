import React, { useState } from 'react';
import {
  Popover,
  DataList,
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  DataListCell,
} from '@patternfly/react-core';
import {
  WarningTriangleIcon,
  OkIcon,
  ErrorCircleOIcon,
  QuestionCircleIcon,
} from '@patternfly/react-icons';
import Modal from './Modal';

const AggregateStatus = ({ statusNumber }) => {
  const [modalStatus, setModalStatus] = useState(false);
  const [popOverStatus, setPopOverStatus] = useState(false);

  const StatusIcon = ({ statusNumber }) => {
    switch (statusNumber) {
      case 0:
        return <OkIcon color="#3E8635" />;
      case 1:
        return <WarningTriangleIcon color="#F0AB00" />;
      case 2:
        return <ErrorCircleOIcon color="#C9190B" />;
      default:
        return <QuestionCircleIcon color="#2B9AF3" />;
    }
  };

  const Content = () => (
    <DataList aria-label="Compact data list example" isCompact>
      <DataListItem aria-labelledby="simple-item2">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell key="secondary content fill">
                <span id="simple-item2">Build</span>
              </DataListCell>,
              <DataListCell key="secondary content align2">
                <span style={{ color: '#F0AB00' }}>
                  <StatusIcon statusNumber={1} /> Out of sync
                </span>
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
      <DataListItem aria-labelledby="simple-item2">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell key="secondary content fill">
                <span id="simple-item2">Configuration</span>
              </DataListCell>,
              <DataListCell key="secondary content align">
                <span style={{ color: '#3E8635' }}>
                  <StatusIcon statusNumber={0} /> Installed
                </span>
              </DataListCell>,
            ]}
          />
        </DataListItemRow>
      </DataListItem>
    </DataList>
  );
  return (
    <>
      <Popover
        position="bottom"
        shouldClose={() => setPopOverStatus(false)}
        onHide={() => setPopOverStatus(false)}
        hasAutoWidth
        isVisible={popOverStatus}
        aria-label="Basic popover"
        headerContent={
          <span>
            Host Status <StatusIcon statusNumber={2} />
          </span>
        }
        bodyContent={<Content />}
        footerContent={
          <span>
            Click <a onClick={() => setModalStatus(true)}>here</a> for all{' '}
            <b>5</b> statuses
          </span>
        }
      >
        <button
          onClick={() => setPopOverStatus(true)}
          style={{ background: 'white', border: 'none' }}
        >
          <StatusIcon statusNumber={2} />
        </button>
      </Popover>
      <Modal
        isOpen={modalStatus}
        closePopover={setPopOverStatus}
        onClose={() => {
          setModalStatus(false);
        }}
      />
    </>
  );
};

export default AggregateStatus;
