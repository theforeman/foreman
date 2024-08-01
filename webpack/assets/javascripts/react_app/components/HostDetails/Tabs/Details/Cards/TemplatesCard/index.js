import React, { useState } from 'react';
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
import { ReviewModal } from './ReviewModal';

const TemplatesCard = ({ hostDetails }) => {
  const { id, managed, name } = hostDetails;

  if (!managed) {
    return null;
  }

  const templatesUrl = foremanUrl(`/api/hosts/${id}/templates`);
  const TemplateTypeTitle = __('Template type');
  const {
    response: {
      templates,
      view_provisioning_templates: viewTemplatePermission,
      edit_provisioning_templates: editTemplatePermission,
    },
    status,
  } = useAPI('get', templatesUrl);
  const editTemplateUrl = tplId => `/templates/provisioning_templates/${tplId}/edit`;
  const [currentTemplate, setCurrentTemplate] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const onReviewClick = template => {
    setCurrentTemplate(template);
    setIsModalOpen(true);
  };
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
        {currentTemplate && (
          <ReviewModal
            isModalOpen={isModalOpen}
            setIsModalOpen={setIsModalOpen}
            hostName={name}
            template={currentTemplate}
          />
        )}
        <TableComposable
          ouiaId="provisioning-templates-table"
          aria-label="templates table"
          variant="compact"
        >
          <Tbody>
            {templates?.map(template => (
              <Tr
                ouiaId={`provisioning-templates-table-row-${template.name}`}
                key={template.name}
              >
                <Td /* to remove padding */ />
                <Td dataLabel={TemplateTypeTitle} noPadding>
                  <Button
                    ouiaId={`provisioning-templates-table-row-${template.name}-name`}
                    isDisabled={!viewTemplatePermission}
                    variant="link"
                    onClick={() => onReviewClick(template)}
                  >
                    {template.name}
                  </Button>
                </Td>
                {editTemplatePermission && (
                  <Td>
                    <Button
                      ouiaId={`provisioning-templates-table-row-${template.name}-edit`}
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
  hostDetails: PropTypes.shape({
    id: PropTypes.number,
    managed: PropTypes.bool,
    name: PropTypes.string,
  }),
};

TemplatesCard.defaultProps = {
  hostDetails: {},
};
