import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';

import {
  Alert,
  AlertActionCloseButton,
  AlertActionLink,
  AlertGroup,
} from '@patternfly/react-core';

import { addToast, deleteToast, selectToastsList } from './slice';
import { toastType, toastTitle, MAX_TOAST_TITLE_LENGTH } from './helpers';
import './style.scss';

const TOAST_TIMEOUT_MS = 8000;

const wrapToastMessage = message =>
  typeof message === 'string' && message.length > MAX_TOAST_TITLE_LENGTH ? (
    <div>{message}</div>
  ) : (
    message
  );

const ToastsList = ({ railsMessages }) => {
  const dispatch = useDispatch();
  const messages = useSelector(selectToastsList);

  useEffect(() => {
    railsMessages.forEach(({ message, type }) => {
      dispatch(addToast({ message, type }));
    });
  }, [dispatch, railsMessages]);

  const toastsList = Object.entries(messages).map(
    ([key, { type, message, link, sticky, ...toastProps }]) => {
      const displayMessage = wrapToastMessage(message);

      return (
        <Alert
          ouiaId={`toast-item-${key}`}
          key={key}
          title={toastTitle(message, toastType(type))}
          variant={toastType(type)}
          timeout={sticky ? false : TOAST_TIMEOUT_MS}
          onTimeout={() => dispatch(deleteToast(key))}
          className="foreman-toast"
          actionClose={
            <AlertActionCloseButton
              onClose={() => dispatch(deleteToast(key))}
            />
          }
          actionLinks={
            link && (
              <AlertActionLink>
                <a href={link.href}>{link.children}</a>
              </AlertActionLink>
            )
          }
          {...toastProps}
        >
          {React.isValidElement(displayMessage) && displayMessage}
        </Alert>
      );
    }
  );

  return (
    toastsList.length > 0 && (
      <AlertGroup isToast className="foreman-toast-group">
        {toastsList}
      </AlertGroup>
    )
  );
};

ToastsList.propTypes = {
  railsMessages: PropTypes.array,
};

ToastsList.defaultProps = {
  railsMessages: [],
};

export default ToastsList;

export * from './slice';
