import React, { useRef } from 'react';
import PropTypes from 'prop-types';
import { OverlayTrigger, Tooltip, Button } from 'patternfly-react';
import { CopyIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';

const CopyToClipboard = ({ valueToCopy }) => {
  const inputRef = useRef(null);
  const tooltip = <Tooltip id="copy-btn-tooltip">{__('Copied!')}</Tooltip>;

  const handleCopy = () => {
    inputRef.current.select();
    document.execCommand('copy');
  };

  return (
    <div className="input-group">
      <input
        className="form-control"
        id="input_to_copy"
        readOnly
        type="text"
        value={valueToCopy}
        ref={inputRef}
      />
      <div className="input-group-btn">
        <OverlayTrigger
          placement="top"
          overlay={tooltip}
          trigger="click"
          rootClose
        >
          <Button bsStyle="default" onClick={handleCopy} className="pull-right">
            <CopyIcon /> {__('Copy')}
          </Button>
        </OverlayTrigger>
      </div>
    </div>
  );
};

CopyToClipboard.propTypes = {
  valueToCopy: PropTypes.string,
};

CopyToClipboard.defaultProps = {
  valueToCopy: null,
};

export default CopyToClipboard;
