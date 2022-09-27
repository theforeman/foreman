import React from 'react';
import PropTypes from 'prop-types';
import { Button } from '@patternfly/react-core';
import { PencilAltIcon } from '@patternfly/react-icons';
import { TableComposable, Tr, Tbody, Td } from '@patternfly/react-table';
import { translate as __ } from '../../../../../../common/I18n';
import { foremanUrl } from '../../../../../../common/helpers';
import { useAPI } from '../../../../../../common/hooks/API/APIHooks';
import SkeletonLoader from '../../../../../common/SkeletonLoader';
import DefaultLoaderEmptyState from '../../../../DetailsCard/DefaultLoaderEmptyState';
import CardTemplate from '../../../../Templates/CardItem/CardTemplate';
import { STATUS } from '../../../../../../constants';

const TemplatesCard = ({ hostName }) => {
  const templatesUrl = foremanUrl(`/api/hosts/${hostName}/templates`);
  const TemplateTypeTitle = __('Template type');
  const {
    response: {
      templates,
      edit_provisioning_templates: editTemplatePermission,
    },
    status,
  } = useAPI('get', templatesUrl);
  const editTemplateUrl = id => `/templates/provisioning_templates/${id}/edit`;
  if (!templates?.length) return null;
  return (
    <CardTemplate
      header={__('Provisioning templates')}
      expandable
      masonryLayout
    >
      <SkeletonLoader
        emptyState={<DefaultLoaderEmptyState />}
        status={status || STATUS.PENDING}
      >
        <TableComposable aria-label="templates table" variant="compact">
          <Tbody>
            {templates?.map(template => (
              <Tr key={template.name}>
                <Td /* to remove padding */ />
                <Td dataLabel={TemplateTypeTitle} noPadding>
                  {template.name}
                </Td>
                {editTemplatePermission && (
                  <Td>
                    <Button
                      component="a"
                      key="edit"
                      href={editTemplateUrl(template.id)}
                      variant="plain"
                      target="_blank"
                    >
                      <PencilAltIcon />
                    </Button>
                  </Td>
                )}
              </Tr>
            ))}
          </Tbody>
        </TableComposable>
      </SkeletonLoader>
    </CardTemplate>
  );
};

export default TemplatesCard;

TemplatesCard.propTypes = {
  hostName: PropTypes.string,
};

TemplatesCard.defaultProps = {
  hostName: undefined,
};
