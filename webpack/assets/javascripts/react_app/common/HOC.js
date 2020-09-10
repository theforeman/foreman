/* eslint-disable react-hooks/exhaustive-deps */
import React, { useEffect, useRef } from 'react';
import EmptyPage from '../routes/common/EmptyPage';
import LoadingPage from '../routes/common/LoadingPage';

/**
 * HOC that runs a function on the initial mount of the component using useEffect
 * @param {Function} callback - function to run
 */
export const callOnMount = callback => WrappedComponent => componentProps => {
  // fires callback onMount, [] means don't listen to any props change
  useEffect(() => {
    callback(componentProps);
  }, []);

  return <WrappedComponent {...componentProps} />;
};

/**
 * HOC that runs a function onPopState if search query has changed,
 * assuming the component has withRouter
 * @param {Function} callback - function to run
 */
export const callOnPopState = callback => WrappedComponent => componentProps => {
  const didMount = useRef(false);
  const {
    history: { action },
    location: { search },
  } = componentProps;
  useEffect(() => {
    if (action === 'POP' && didMount.current) {
      callback(componentProps);
    } else {
      didMount.current = true;
    }
  }, [search, action]);

  return <WrappedComponent {...componentProps} />;
};

/**
 * HOC That renders a component based on its state
 *
 * the following root Component props are required
 * { isLoading, hasData, hasError }
 *
 * If the default Error and Empty Components are used
 * the following props are also required:
 *
 * { message: { type, text }}
 * @param {ReactElement} Component - Component to render
 * @param {ReactElement} LoadingComponent - Component to render if Loading
 * @param {ReactElement} ErrorComponent - Component to render if Error
 * @param {ReactElement} EmptyComponent - Component to render if no Data exists
 */
export const withRenderHandler = ({
  Component,
  LoadingComponent = LoadingPage,
  ErrorComponent = EmptyPage,
  EmptyComponent = EmptyPage,
}) => componentProps => {
  const { isLoading, hasData, hasError } = componentProps;

  if (isLoading && !hasData) return <LoadingComponent {...componentProps} />;
  if (hasError) return <ErrorComponent {...componentProps} />;
  if (hasData) return <Component {...componentProps} />;
  return <EmptyComponent {...componentProps} />;
};
