import React, { Fragment } from 'react';
import { Button, Icon } from '@patternfly/react-core';
import { KeyIcon } from '@patternfly/react-icons';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { openConfirmModal } from '../../ConfirmModal';
import { APIActions } from '../../../redux/API';
import { translate as __ } from '../../../common/I18n';

const JwtTokens = ({ userId }) => {
  const dispatch = useDispatch();
  return (
    <Fragment>
      <table className="table table-bordered table-striped table-hover table-fixed">
        <tbody>
          <tr>
            <td className="blank-slate-pf">
              <div className="blank-slate-pf-icon">
                <Icon>
                  <KeyIcon />
                </Icon>
              </div>
              <h1>{__('JWT Tokens')}</h1>
              <p>
                {__(
                  'By invalidating your JSON Web Tokens (JWTs), you will no longer be able to register hosts by using your existing JWTs.'
                )}
              </p>
              <Button
                ouiaId="invalidate-jwt-token-button"
                variant="primary"
                size="sm"
                onClick={() =>
                  dispatch(
                    openConfirmModal({
                      isWarning: true,
                      title: __('Invalidate tokens for self?'),
                      confirmButtonText: __('Confirm'),
                      onConfirm: () =>
                        dispatch(
                          APIActions.patch({
                            url: `/users/${userId}/invalidate_jwt`,
                            key: `INVALIDATE-JWT`,
                            successToast: () =>
                              __(
                                'Successfully Invalidated registration tokens.'
                              ),
                            errorToast: () => __('Unexpected error occurred.'),
                          })
                        ),
                    })
                  )
                }
              >
                {__('Invalidate JWTs')}
              </Button>
            </td>
          </tr>
        </tbody>
      </table>
    </Fragment>
  );
};

JwtTokens.propTypes = {
  userId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
};

export default JwtTokens;
