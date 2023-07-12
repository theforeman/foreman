import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { Tabs, Tab, TabTitleText } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import { INPUT, DIFF, PREVIEW } from '../EditorConstants';
import { EditorContext } from '../EditorContext';

const EditorTabs = ({
  isRendering,
  toggleRenderView,
  showPreview,
  isDiff,
  selectedHost,
  fetchAndPreview,
  selectedRenderPath,
  templateKindId,
  showHostSelector,
}) => {
  const { selectedView, setSelectedView } = useContext(EditorContext);

  return (
    <Tabs activeKey={selectedView}>
      <Tab
        id={`tab-${INPUT}`}
        key={INPUT}
        eventKey={INPUT}
        onClick={() => {
          if (selectedView !== INPUT) {
            if (isRendering) toggleRenderView();
            setSelectedView(INPUT);
          }
        }}
        title={<TabTitleText>{__('Editor')}</TabTitleText>}
      />
      <Tab
        id={`tab-${DIFF}`}
        key={DIFF}
        eventKey={DIFF}
        disabled={!isDiff}
        onClick={() => {
          if (selectedView !== DIFF) {
            setSelectedView(DIFF);
          }
        }}
        title={<TabTitleText>{__('Changes')}</TabTitleText>}
      />
      {showPreview && (
        <Tab
          id={`tab-${PREVIEW}`}
          key={PREVIEW}
          eventKey={PREVIEW}
          onClick={() => {
            if (selectedView !== PREVIEW) {
              if (!isRendering) toggleRenderView();
              setSelectedView(PREVIEW);
              if (selectedHost.id === '')
                fetchAndPreview(
                  selectedRenderPath,
                  templateKindId,
                  !showHostSelector
                );
            }
          }}
          title={<TabTitleText>{__('Preview')}</TabTitleText>}
        />
      )}
    </Tabs>
  );
};

EditorTabs.propTypes = {
  isRendering: PropTypes.bool.isRequired,
  toggleRenderView: PropTypes.func.isRequired,
  showPreview: PropTypes.bool.isRequired,
  isDiff: PropTypes.bool.isRequired,
  selectedHost: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    name: PropTypes.string,
  }).isRequired,
  fetchAndPreview: PropTypes.func.isRequired,
  selectedRenderPath: PropTypes.string.isRequired,
  templateKindId: PropTypes.string.isRequired,
  showHostSelector: PropTypes.bool.isRequired,
};

export default EditorTabs;
