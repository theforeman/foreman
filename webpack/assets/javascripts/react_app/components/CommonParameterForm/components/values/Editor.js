import React from 'react';
import PropTypes from 'prop-types';
import AceEditor from 'react-ace';

const Editor = ({ id, name, mode, value, onChange, fullScreen, isMasked }) => (
  <AceEditor
    mode={mode}
    id={id}
    name={name}
    theme="github"
    width="100%"
    height="150px"
    tabSize={2}
    editorProps={{ $blockScrolling: 'Infinity' }}
    value={`${value}`}
    onChange={val => onChange(val)}
    className={`common-param-editor ${fullScreen && 'fullscreen'} ${isMasked &&
      'mask-editor'}`}
    showPrintMargin={false}
    showLineNumbers
  />
);

Editor.propTypes = {
  id: PropTypes.string,
  name: PropTypes.string.isRequired,
  mode: PropTypes.string.isRequired,
  value: PropTypes.any,
  onChange: PropTypes.func.isRequired,
  fullScreen: PropTypes.bool,
  isMasked: PropTypes.bool,
};

Editor.defaultProps = {
  id: '',
  value: '',
  fullScreen: false,
  isMasked: false,
};

export default Editor;
