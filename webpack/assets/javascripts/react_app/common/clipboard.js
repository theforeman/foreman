const legacyCopy = text => {
  const textarea = document.createElement('textarea');
  textarea.value = text;
  textarea.setAttribute('readonly', '');
  textarea.style.position = 'fixed';
  textarea.style.opacity = '0';
  document.body.appendChild(textarea);
  textarea.select();
  try {
    document.execCommand('copy');
  } finally {
    textarea.remove();
  }
};

export const copyToClipboard = async (_event, text) => {
  try {
    await navigator.clipboard.writeText(text);
  } catch {
    legacyCopy(text);
  }
};
