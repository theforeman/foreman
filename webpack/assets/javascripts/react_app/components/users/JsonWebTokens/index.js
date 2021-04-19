import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { Icon } from 'patternfly-react';

import { translate as __ } from '../../../common/I18n';
import { foremanUrl } from '../../../common/helpers';
import { useForemanModal } from '../../ForemanModal/ForemanModalHooks';
import { useForemanUser } from '../../../Root/Context/ForemanContext';
import { API } from '../../../redux/API';
import { addToast } from '../../../redux/actions/toasts';
import { submitForm } from '../../../redux/actions/common/forms';

import Generate from './components/Generate';
import Invalidate from './components/Invalidate';
import Token from './components/Token';
import Info from './components/Info';

import { selectGenerateApiStatus, selectJsonWebToken } from './Selectors';
import { GENERATE_JWT_MODAL_ID, INVALIDATE_JWT_MODAL_ID } from './Constants';

const JsonWebTokens = () => {
  const dispatch = useDispatch();
  const user = useForemanUser();
  const url = foremanUrl(`/api/v2/users/${user.id}/json_web_tokens`);
  const generateModal = useForemanModal({
    id: GENERATE_JWT_MODAL_ID,
  });
  const invalidateModal = useForemanModal({
    id: INVALIDATE_JWT_MODAL_ID,
  });

  const token = useSelector(selectJsonWebToken);
  const generateStatus = useSelector(selectGenerateApiStatus);

  const handleGenerate = values => {
    dispatch(
      submitForm({
        url,
        values,
        item: 'json_web_tokens',
        message: __('Token successfully generated'),
        errorToast: () =>
          __(
            'Could not generate token, see the application log for more information'
          ),
        successCallback: () => generateModal.setModalClosed(),
      })
    );
  };

  const invalidateToken = async () => {
    try {
      const result = await API.delete(url);
      dispatch(
        addToast({
          type: 'success',
          message: result.data.message,
        })
      );
    } catch (_error) {
      dispatch(
        addToast({
          type: 'error',
          message: __(
            'Could not invalidate JSON web tokens, see the application log for more information'
          ),
        })
      );
    }

    invalidateModal.setModalClosed();
  };

  return (
    <>
      <table className="table table-bordered table-striped table-hover table-fixed">
        <tbody>
          <tr>
            <td className="blank-slate-pf">
              <div className="blank-slate-pf-icon">
                <Icon type="fa" name="key" color="#9c9c9c" />
              </div>
              <h1>{__('JSON web tokens')}</h1>
              <div>
                <Generate
                  url={url}
                  handleSubmit={handleGenerate}
                  modalActions={generateModal}
                />
                &nbsp;
                <Invalidate
                  handleSubmit={invalidateToken}
                  modalActions={invalidateModal}
                />
              </div>
              <Token token={token} status={generateStatus} />
              <Info />
            </td>
          </tr>
        </tbody>
      </table>
    </>
  );
};

export default JsonWebTokens;
