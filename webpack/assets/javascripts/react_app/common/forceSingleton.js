/**
 * Force a single instance to protect from code duplication.
 *
 * WARNING: Code duplications happen because of an issue with the build process,
 *          so this method might be removed once the issue would be fixed.
 *          See: https://projects.theforeman.org/issues/27195
 *
 * @param  {String}   key    A unique-key to save the instance.
 * @param  {Function} create A function to create an instance.
 * @return {*}               Single Instance,
 *                           returned by the create method or from the cache.
 */
const forceSingleton = (key, create) => {
  window.tfm_forced_singletons = window.tfm_forced_singletons || {};

  if (!window.tfm_forced_singletons[key]) {
    window.tfm_forced_singletons[key] = create();
  }

  return window.tfm_forced_singletons[key];
};

export default forceSingleton;
