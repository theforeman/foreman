import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  ClipboardCopy,
  ClipboardCopyVariant,
  Button,
  Modal,
  Switch,
  Tooltip,
} from '@patternfly/react-core';
import { OutlinedWindowRestoreIcon } from '@patternfly/react-icons';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from '../../../../../../common/I18n';
import { useAPI } from '../../../../../../common/hooks/API/APIHooks';
import SkeletonLoader from '../../../../../common/SkeletonLoader';
import { STATUS } from '../../../../../../constants';
import { useForemanSettings } from '../../../../../../Root/Context/ForemanContext';

export const ReviewModal = ({
  isModalOpen,
  setIsModalOpen,
  template,
  hostName,
}) => {
  const { safeMode } = useForemanSettings();
  const [showSafe, setShowSafe] = useState(true);
  const url = `/unattended/${template.kind}?force_safemode=${showSafe}&hostname=${hostName}`;
  const { response, status } = useAPI('get', url);
  return (
    <Modal
      isOpen={isModalOpen}
      onClose={() => setIsModalOpen(false)}
      variant="large"
      title={
        <div>
          {template.name}{' '}
          <Tooltip content={__('Open in a new tab')}>
            <Button
              aria-label="Open in a new tab"
              component="a"
              isInline
              href={url}
              variant="link"
              icon={<OutlinedWindowRestoreIcon />}
              target="_blank"
              rel="external noreferrer noopener"
            />
          </Tooltip>
        </div>
      }
    >
      <div>
        <FormattedMessage
          id="build"
          values={{
            openTemplate: (
              <Button
                aria-label="Open template edit page"
                component="a"
                key="edit-template"
                href={`/templates/provisioning_templates/${template.id}/edit`}
                variant="link"
                target="_blank"
                rel="external noreferrer noopener"
                isInline
              >
                {template.name}
              </Button>
            ),
          }}
          defaultMessage={__('View provisioning template {openTemplate}.')}
        />
      </div>
      {!safeMode && (
        <div
          style={{
            paddingTop: 'var(--pf-global--spacer--lg)',
            paddingBottom: 'var(--pf-global--spacer--lg)',
          }}
        >
          <Switch
            id="safe-mode-switch"
            label={__('Safe mode on')}
            labelOff={__('Safe mode off')}
            isChecked={showSafe}
            onChange={setShowSafe}
          />
        </div>
      )}
      <SkeletonLoader
        skeletonProps={{ count: 10 }}
        status={status || STATUS.PENDING}
      >
        {response && (
          <ClipboardCopy
            isExpanded
            isReadOnly
            isCode
            variant={ClipboardCopyVariant.expansion}
          >
            {response}
          </ClipboardCopy>
        )}
      </SkeletonLoader>
    </Modal>
  );
};

ReviewModal.propTypes = {
  isModalOpen: PropTypes.bool.isRequired,
  setIsModalOpen: PropTypes.func.isRequired,
  template: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    kind: PropTypes.string,
  }).isRequired,
  hostName: PropTypes.string.isRequired,
};
