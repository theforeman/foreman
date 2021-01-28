import React from 'react';
import { Formik } from 'formik';
import PropTypes from 'prop-types';
import Form from '../Form';
import { translate as __ } from '../../../../common/I18n';

export const prepareErrors = errors =>
  Object.keys(errors).reduce((memo, key) => {
    const errorMessages = errors[key];

    memo[key] =
      errorMessages && errorMessages.join
        ? errorMessages.join(', ')
        : errorMessages;
    return memo;
  }, {});

export const isInitialValid = ({ validationSchema, initialValues }) =>
  !validationSchema ? true : validationSchema.isValidSync(initialValues);

const ForemanForm = props => (
  <Formik
    onSubmit={(values, actions) =>
      props.onSubmit(values, actions).catch(exception => {
        actions.setSubmitting(false);
        actions.setErrors(prepareErrors(exception.errors));
      })
    }
    initialValues={props.initialValues}
    validationSchema={props.validationSchema}
    isInitialValid={isInitialValid}
    enableReinitialize={props.enableReinitialize}
  >
    {formProps => {
      const disabled = formProps.isSubmitting || !formProps.isValid;

      const submissionError = formProps.errors._error;
      return (
        <Form
          onSubmit={formProps.handleSubmit}
          onCancel={props.onCancel}
          disabled={disabled}
          error={submissionError}
          errorTitle={
            submissionError && submissionError.severity === 'danger'
              ? __('Error! ')
              : __('Warning! ')
          }
          submitting={formProps.isSubmitting}
        >
          {cloneChildren(props.children, { formProps, disabled })}
        </Form>
      );
    }}
  </Formik>
);

const cloneChildren = (children, childProps) => (
  <React.Fragment>
    {children.map
      ? children.map((child, idx) =>
          React.cloneElement(child, { ...childProps, key: idx })
        )
      : React.cloneElement(children, { ...childProps })}
  </React.Fragment>
);

ForemanForm.propTypes = {
  onSubmit: PropTypes.func.isRequired,
  onCancel: PropTypes.func.isRequired,
  initialValues: PropTypes.object.isRequired,
  validationSchema: PropTypes.object,
  children: PropTypes.oneOfType([PropTypes.object, PropTypes.array]).isRequired,
  enableReinitialize: PropTypes.bool,
};

ForemanForm.defaultProps = {
  validationSchema: undefined,
  enableReinitialize: false,
};

export default ForemanForm;
