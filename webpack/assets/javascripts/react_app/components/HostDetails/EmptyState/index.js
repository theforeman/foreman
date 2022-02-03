import PropTypes from 'prop-types';
import React from 'react';
import { Redirect } from 'react-router-dom';
import { translate as __, sprintf } from '../../../common/I18n';
import { foremanUrl } from '../../../common/helpers';

const RedirectToEmptyHostPage = ({ hostname }) => (
  <Redirect
    to={{
      pathname: '/page-not-found',
      state: {
        back: true,
        header: __('No host found'),
        body: sprintf(
          __(
            `The host %s does not exist or there are access permissions needed. Please contact your administrator if this issue continues.`
          ),
          hostname
        ),
        action: {
          title: __('All hosts'),
          url: foremanUrl('/hosts'),
        },
        secondayActions: [
          {
            title: __('Create a host'),
            url: foremanUrl('/hosts/new'),
          },
        ],
      },
    }}
  />
);

RedirectToEmptyHostPage.propTypes = {
  hostname: PropTypes.string.isRequired,
};

export default RedirectToEmptyHostPage;
