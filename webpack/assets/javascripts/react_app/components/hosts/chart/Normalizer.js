const Normalizer = (vector) => {
  if (vector.length === 0) {
    return { columns: [] };
  }
  const data = {
    x: 'time',
  };
  const timeFrame = vector[0].data.map(ts => ts[0]);
  const tsItems = vector.map(item => [item.label, ...item.data.map(ts => ts[1])]);
  data.columns = [['time', ...timeFrame], ...tsItems];
  const colorItems = vector.filter(item => Object.prototype.hasOwnProperty.call(item, 'color'));
  if (colorItems.length === 0) {
    return data;
  }
  const colorReducer = (acc, cur) => Object.assign({}, { ...acc, [cur.label]: cur.color });
  data.colors = { ...colorItems.reduce(colorReducer, {}) };
  return data;
};

export default Normalizer;
