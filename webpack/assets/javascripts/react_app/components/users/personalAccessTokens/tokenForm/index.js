import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import Form from '../../../common/forms/Form';
import TextField from '../../../common/forms/TextField';
import { required, length, date } from 'redux-form-validators';
import * as FormActions from '../../../../redux/actions/common/forms';

class TokenForm extends React.Component {
  // eslint-disable-next-line camelcase
  submit({ name, expires_at }, dispatch, props) {
    const { url, submitForm } = props;
    // eslint-disable-next-line camelcase
    const values = { name, expires_at };

    return submitForm({ url, values, item: 'PersonalAccessToken', successAction: 'USERS_PERSONAL_ACCESS_TOKEN_FORM_SUCCESS' });
  }

  render() {
    const { handleSubmit, hideForm, submitting, error } = this.props;

    return (
      <Form
        onSubmit={handleSubmit(this.submit)}
        onCancel={hideForm}
        disabled={submitting}
        submitting={submitting}
        error={error}
      >
        <TextField
          name="name"
          type="text"
          required="true"
          label={__('Name')}
          validate={[required(), length({ max: 254 })]}
        />
        <TextField
          name="expires_at"
          type="date"
          label={__('Expires at')}
          validate={[
            date({
              // eslint-disable-next-line camelcase
              unless: ({ expires_at }) => {
                // eslint-disable-next-line camelcase
                return expires_at === undefined;
              },
              format: 'yyyy-mm-dd',
              '>': 'today'
            })
          ]}
        />
      </Form>
    );
  }
}

const form = reduxForm({
  form: 'personal_access_token_create'
})(TokenForm);

export default connect(
  state => ({
    // eslint-disable-next-line camelcase
    initialValues: { expires_at: new Date().toISOString() }
  }),
  FormActions
)(form);
