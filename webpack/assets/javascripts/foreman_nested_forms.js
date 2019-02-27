export function fixTemplateNames(content, assoc, newId) {
  const regexp = new RegExp(`new_${assoc}`, 'g');
  return content.replace(regexp, newId);
}
