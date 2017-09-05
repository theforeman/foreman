import _ from 'lodash';

let pluginEditAttributes = {
  architecture: [],
  os: [],
  medium: [],
  image: []
};

export function registerPluginAttributes(componentType, attributes) {
  if (pluginEditAttributes[componentType] !== undefined) {
    pluginEditAttributes[componentType] = _.uniq(
      pluginEditAttributes[componentType].concat(attributes));
  }
}

export function getAttributesToPost(componentType) {
  const defaultAttributes = {
    'architecture': ['architecture_id', 'organization_id', 'location_id'],
    'os': ['operatingsystem_id', 'organization_id', 'location_id'],
    'medium': ['medium_id', 'operatingsystem_id', 'architecture_id'],
    'image': ['medium_id', 'operatingsystem_id', 'architecture_id', 'model_id']
  };
  let attrsToPost = defaultAttributes[componentType];

  if (attrsToPost === undefined) {
    return [];
  }
  if (pluginEditAttributes[componentType] !== undefined) {
      attrsToPost = attrsToPost.concat(pluginEditAttributes[componentType]);
  }
  return _.uniq(attrsToPost);
}
