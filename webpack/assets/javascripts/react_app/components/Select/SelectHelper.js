export const createItemProps = (item, selectedItem, className, onItemClick) => {
  const key = `${item.id}-${item.name}`;
  const itemProps = {
    key,
    id: key,
    className,
    active: selectedItem.id === item.id,
  };

  if (item.disabled) return { ...itemProps, disabled: true };
  return {
    ...itemProps,
    onClick: e => onItemClick({ e, id: item.id, name: item.name }),
  };
};
