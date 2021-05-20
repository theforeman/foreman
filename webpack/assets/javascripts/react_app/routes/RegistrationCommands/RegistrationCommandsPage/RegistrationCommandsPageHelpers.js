/* eslint-disable camelcase */
import React from 'react';
import { FormSelectOption } from '@patternfly/react-core';

import { foremanUrl } from '../../../../foreman_tools';
import { sprintf, translate as __ } from '../../../common/I18n';

// Form helpers
export const emptyOption = length => (
  <FormSelectOption
    value=""
    label={length > 0 ? '' : __('Nothing to select.')}
  />
);

// OperatingSystem helpers

export const validatedOS = (operatingSystemId, template) => {
  if (!operatingSystemId) {
    return 'default';
  }

  if (template?.name) {
    return 'success';
  }
  return 'error';
};

export const osHelperText = (
  operatingSystemId,
  operatingSystems,
  hostGroupId,
  hostGroups,
  template
) => {
  if (operatingSystemId) {
    return osTemplateHelperText(operatingSystemId, template);
  }

  if (hostGroupId) {
    const osId = hostGroups.find(hg => `${hg.id}` === `${hostGroupId}`)
      ?.operatingsystem_id;
    return (
      <>
        {hostGroupOSHelperText(hostGroupId, hostGroups, operatingSystems)}
        <br />
        {osId && osTemplateHelperText(osId, template)}
      </>
    );
  }

  return '';
};

const osTemplateHelperText = (operatingSystemId, template) => {
  if (!operatingSystemId && template === undefined) {
    return <>&nbsp;</>;
  }

  if (template?.name) {
    return (
      <span>
        {__('Initial configuration template')}:{' '}
        <a href={foremanUrl(template.path)} target="_blank" rel="noreferrer">
          {template.name}
        </a>
      </span>
    );
  }

  return (
    <span className="has-error">
      <a href={foremanUrl(template.os_path)} target="_blank" rel="noreferrer">
        {__('Operating system')}
      </a>{' '}
      {__('does not have assigned host_init_config template')}
    </span>
  );
};

const hostGroupOSHelperText = (hostGroupId, hostGroups, operatingSystems) => {
  const osId = hostGroups.find(hg => `${hg.id}` === `${hostGroupId}`)
    ?.operatingsystem_id;
  const hostGroupOS = operatingSystems.find(os => `${os.id}` === `${osId}`);

  if (hostGroupOS) {
    return sprintf('Host group OS: %s', hostGroupOS.title);
  }
  return __('No OS from host group');
};
