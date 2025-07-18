import { useForemanModal } from '../ForemanModal/ForemanModalHooks';

import { SETTING_UPDATE_MODAL } from './SettingUpdateModalConstants';

const useSettingModal = () => useForemanModal({ id: SETTING_UPDATE_MODAL });

export default useSettingModal;
