import React from 'react';
import PropTypes from 'prop-types';

import ForemanModal from '../ForemanModal';
import { sprintf, translate as __ } from '../../common/I18n';

import SettingForm from './components/SettingForm';

import { SETTING_UPDATE_MODAL } from './SettingUpdateModalConstants';

const SettingUpdateModal = ({ setting, setModalClosed }) => (
  <ForemanModal
    id={SETTING_UPDATE_MODAL}
    title={sprintf(__('Update value for %s setting'), setting.fullName)}
    enforceFocus
  >
    <div>
      <SettingForm setting={setting} setModalClosed={setModalClosed} />
    </div>
  </ForemanModal>
);

SettingUpdateModal.propTypes = {
  setting: PropTypes.object.isRequired,
  setModalClosed: PropTypes.func.isRequired,
};

export default SettingUpdateModal;
