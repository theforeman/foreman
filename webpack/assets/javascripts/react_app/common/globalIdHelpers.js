/*
 * Helpers for dealing with GlobalIDs as returned by GraphQL. When `id` property is
 * retrieved through GraphQL, the value is not a "native" ID under which the
 * backend knows the record in question.
 *
 * The GlobalID contains a version number, model class and the id itself, put
 * together into a single string and encoded as base64.
 */

const idSeparator = '-';
const versionSeparator = ':';
const defaultVersion = '01';

// Decodes the provided GlobalID, returns a three element array consisting of
// version, type name and id as strings
export const decode = globalId => {
  const s = Buffer.from(globalId, 'base64').toString();
  let i = s.indexOf(versionSeparator);
  const version = parseInt(s.substring(0, i), 10);
  const payload = s.substring(i + 1);

  i = payload.indexOf(idSeparator);
  const type = payload.substring(0, i);
  const id = payload.substring(i + 1);

  return { version, type, id };
};

// Retrieves the ID part of given GlobalID string
export const getId = globalId => decode(globalId).id;

// Retrieves a numerical ID from object representing the record, expects the id
// property of the object to be a GlobalID
export const decodeModelId = ({ id }) => decodeId(id);

// Similar to getId, but also parses the result as Integer This should be
// preferred over getId, where possible. getId is still useful for resources
// with non-numeric IDs
export const decodeId = id => parseInt(getId(id), 10);

// Generates a GlobalID string from provided resource type and its ID
export const encodeId = (typename, id) => {
  const str = [
    defaultVersion,
    versionSeparator,
    typename,
    idSeparator,
    id,
  ].join('');
  return Buffer.from(str).toString('base64');
};
