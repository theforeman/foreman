/**
 * This file exists so files from the asset pipline can use lodash
 * The only used methods from lodash are:
 * - get
 * - escape
 *
 * Long term goals:
 * 1. move the assets pipline to webpack
 * 2. reduce the usage of lodash in asset pipline and webpack
 *
 * TODO: Once lodash is not relevant to the asset pipline anymore,
 *       remove this file
 */

import { get, escape } from 'lodash';

window._ = { get, escape };
