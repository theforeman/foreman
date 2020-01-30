import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { Row, Col, Tabs, Tab } from 'patternfly-react';
import TabPaneContent from './TabPaneContent';
import SettingUpdateModal from './SettingUpdateModal';
import ErrorPage from './ErrorPage';

import LoadingPage from '../../../common/LoadingPage';
import { withRenderHandler } from '../../../../common/HOC';

import { SETTINGS_MODAL } from '../../constants';

import { demodulize, stickGeneralFirst } from '../SettingsPageHelpers';

import { useForemanModal } from '../../../../components/ForemanModal/ForemanModalHooks';

import './SettingsPageContent.scss';

const SettingsPageContent = ({ groupedSettings }) => {
  const [toUpdate, setToUpdate] = useState({});
  const [active, setActive] = useState(0);

  const { setModalOpen, setModalClosed } = useForemanModal({
    id: SETTINGS_MODAL,
  });

  const onEditClick = setting => {
    setToUpdate(setting);
    setModalOpen();
  };

  return (
    <Row id="settings-page-content">
      <Col md={12}>
        <SettingUpdateModal
          setting={toUpdate}
          setModalClosed={setModalClosed}
        />

        <Tabs
          id="settings-tabs"
          activeKey={active}
          onSelect={key => setActive(key)}
        >
          {stickGeneralFirst(Object.keys(groupedSettings)).map(
            (category, index) => (
              <Tab key={category} eventKey={index} title={demodulize(category)}>
                <TabPaneContent
                  category={category}
                  settings={groupedSettings[category]}
                  onEditClick={onEditClick}
                />
              </Tab>
            )
          )}
        </Tabs>
      </Col>
    </Row>
  );
};

SettingsPageContent.propTypes = {
  groupedSettings: PropTypes.object.isRequired,
};

export default withRenderHandler({
  Component: SettingsPageContent,
  LoadingComponent: LoadingPage,
  ErrorComponent: ErrorPage,
});
