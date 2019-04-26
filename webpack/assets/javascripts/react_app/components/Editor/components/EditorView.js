import React from 'react';
import PropTypes from 'prop-types';
import AceEditor from 'react-ace';

import 'brace/mode/ruby';
import 'brace/mode/json';
import 'brace/mode/sh';
import 'brace/mode/html_ruby';
import 'brace/mode/xml';
import 'brace/mode/yaml';

import 'brace/theme/github';
import 'brace/theme/monokai';

import 'brace/keybinding/vim';
import 'brace/keybinding/emacs';

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
  value,
}) => (
  <AceEditor
    value={value}
    mode={mode.toLowerCase()}
    theme={theme.toLowerCase()}
    keyboardHandler={keyBinding === 'Default' ? null : keyBinding.toLowerCase()}
    onChange={(editorValue, event) => onChange(editorValue)}
    name={name}
    className={isMasked ? `${className} mask-editor` : className}
    readOnly={readOnly}
    editorProps={{ $blockScrolling: Infinity }}
    showPrintMargin={false}
    debounceChangePeriod={250}
  />
);
EditorView.propTypes = {
  mode: PropTypes.string.isRequired,
  theme: PropTypes.string.isRequired,
  keyBinding: PropTypes.string.isRequired,
  onChange: PropTypes.func,
  readOnly: PropTypes.bool.isRequired,
  name: PropTypes.string.isRequired,
  value: PropTypes.string,
  className: PropTypes.string,
  isMasked: PropTypes.bool.isRequired,
};
EditorView.defaultProps = {
  className: '',
  onChange: noop,
  value: '</>',
};
export default EditorView;
