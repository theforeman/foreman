const selectTemplates = state => state.templates;

const selectGeneratingPropsFromTemplates = ({
  polling,
  dataUrl,
  generatingError,
  generatingErrorMessages,
}) => ({
  polling,
  dataUrl,
  generatingError,
  generatingErrorMessages,
});

export const selectGeneratingProps = state =>
  selectGeneratingPropsFromTemplates(selectTemplates(state));
