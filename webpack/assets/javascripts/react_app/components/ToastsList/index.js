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
import { toastType, toastTitle } from './helpers';
import './style.scss';

const ToastsList = ({ railsMessages }) => {
  const dispatch = useDispatch();
  const messages = useSelector(selectToastsList);

  useEffect(() => {
    railsMessages.forEach(({ message, type, key }) => {
      dispatch(addToast({ message, type, key }));
    });
  }, [dispatch, railsMessages]);

  const toastsList = Object.entries(messages).map(
    ([key, { type, message, link, sticky, ...toastProps }]) => (
      <Alert
        key={key}
        title={toastTitle(message, toastType(type))}
        variant={toastType(type)}
        timeout={sticky ? false : 8000}
        onTimeout={() => dispatch(deleteToast(key))}
        className="foreman-toast"
        actionClose={
          <AlertActionCloseButton onClose={() => dispatch(deleteToast(key))} />
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
        {(message.length > 60 || React.isValidElement(message)) && message}
      </Alert>
    )
  );

  return toastsList.length > 0 && <AlertGroup isToast>{toastsList}</AlertGroup>;
};

ToastsList.propTypes = {
  railsMessages: PropTypes.array,
};

ToastsList.defaultProps = {
  railsMessages: [],
};

export default ToastsList;

export * from './slice';
