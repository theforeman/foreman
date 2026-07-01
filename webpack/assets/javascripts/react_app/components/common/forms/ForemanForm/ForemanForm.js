import React, { useEffect } from 'react';
import { Formik } from 'formik';
import PropTypes from 'prop-types';
import Form from '../Form';
import { translate as __ } from '../../../../common/I18n';
import { deprecate } from '../../../../common/DeprecationService';

export const isInitialValid = ({ validationSchema, initialValues }) =>
  !validationSchema ? true : validationSchema.isValidSync(initialValues);

const ForemanForm = ({
  onSubmit,
  children,
  initialValues,
  validationSchema,
  enableReinitialize,
  onCancel,
}) => {
  useEffect(() => {
    deprecate(
      `forms/ForemanForm/ForemanForm`,
      'Form from @patternfly/react-core',
      '5.1'
    );
  }, []);

  return (
    <Formik
      onSubmit={onSubmit}
      initialValues={initialValues}
      validationSchema={validationSchema}
      isInitialValid={isInitialValid}
      enableReinitialize={enableReinitialize}
    >
      {formProps => {
        const disabled = formProps.isSubmitting || !formProps.isValid;
        const submissionError = formProps.errors._error;

        return (
          <Form
            onSubmit={formProps.handleSubmit}
            onCancel={onCancel}
            disabled={disabled}
            error={submissionError}
            errorTitle={
              submissionError?.severity === 'danger'
                ? __('Error! ')
                : __('Warning! ')
            }
            submitting={formProps.isSubmitting}
          >
            {cloneChildren(children, { formProps, disabled })}
          </Form>
        );
      }}
    </Formik>
  );
};

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
