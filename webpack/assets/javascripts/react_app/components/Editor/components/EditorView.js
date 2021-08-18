import React from 'react';
import PropTypes from 'prop-types';
import AceEditor from 'react-ace';
import classNames from 'classnames';
import 'brace/ext/searchbox';
import { noop } from '../../../common/helpers';

const EditorView = ({
  className,
  isMasked,
  keyBinding,
  mode,
  name,
  onChange,
  readOnly,
  theme,
  autocompletion,
  liveAutocompletion,
  value,
  isSelected,
}) => (
  <AceEditor
    value={value}
    mode={mode.toLowerCase()}
    theme={theme.toLowerCase()}
    keyboardHandler={keyBinding === 'Default' ? null : keyBinding.toLowerCase()}
    onChange={(editorValue, event) => onChange(editorValue)}
    name={name}
    className={classNames({
      [className]: isSelected,
      'mask-editor': isMasked,
      hidden: !isSelected,
    })}
    readOnly={readOnly}
    editorProps={{ $blockScrolling: Infinity }}
    showPrintMargin={false}
    debounceChangePeriod={250}
    enableBasicAutocompletion={autocompletion}
    enableLiveAutocompletion={autocompletion && liveAutocompletion}
  />
);
EditorView.propTypes = {
  mode: PropTypes.string.isRequired,
  theme: PropTypes.string.isRequired,
  autocompletion: PropTypes.bool.isRequired,
  liveAutocompletion: PropTypes.bool.isRequired,
  keyBinding: PropTypes.string.isRequired,
  onChange: PropTypes.func,
  readOnly: PropTypes.bool.isRequired,
  name: PropTypes.string.isRequired,
  value: PropTypes.string,
  className: PropTypes.string,
  isMasked: PropTypes.bool.isRequired,
  isSelected: PropTypes.bool,
};
EditorView.defaultProps = {
  className: '',
  onChange: noop,
  value: '</>',
  isSelected: true,
};
export default EditorView;
