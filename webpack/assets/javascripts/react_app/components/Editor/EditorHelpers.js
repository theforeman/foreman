import {
  isEmpty,
  filter,
  find,
  replace,
  capitalize,
  forEach,
  concat,
  sortBy,
} from 'lodash';

import ace from 'brace';
import 'brace/ext/language_tools';

const resolveDefault = ({ default: defValue }) => {
  switch (typeof defValue) {
    case 'object':
      if (defValue === null) return 'nil';

      return '{}';
    case 'string':
      if (defValue === '') return '""';

      return `"${defValue}"`;
    default:
      return defValue;
  }
};

const methodReturns = ({ returns: { object: retObject } }) => {
  // TODO: add support for Hash return object with nested description
  // can be skipped for now since we don't use it yet and it wasn't tested properly
  if (retObject.class === 'Hash' && retObject.data.constructor === Array)
    return 'Object';
  const retMeta = capitalize(replace(retObject.meta, '_', ' '));
  const retData = replace(JSON.stringify(retObject.data), 'null', 'nil');
  const returns = retObject.data === null ? retObject.class : retData;
  return `${retMeta}: ${returns}`;
};

const methodTooltip = (method, isMacro) => {
  const usagePrefix = isMacro ? '' : 'obj.';
  const usage = `Usage:\n\t${usagePrefix}${methodSignature(method)}`;
  const returns = `Returns:\n\t${methodReturns(method)}`;
  if (isEmpty(method.examples))
    return [method.short_description, usage, returns].join('\n\n');

  let examples = method.examples
    .map(e => {
      const desc = e.desc ? `${e.desc}\n\n` : '';
      return `${desc}${e.example}`;
    })
    .join('\n\n');
  examples = `Examples:\n\n${examples}`;
  return [method.short_description, usage, returns, examples].join('\n\n');
};

const methodSignature = (method, isSnippet) => {
  if (isEmpty(method.params)) return method.name;

  let currParam = 1;
  const params = method.params.map(p => {
    switch (p.type) {
      case 'required':
        return isSnippet ? `\${${currParam++}:${p.name}}` : p.name;
      case 'optional': {
        if (p.expected_type === 'list') {
          return isSnippet
            ? `\${${currParam++}:first},\${${currParam++}:second}`
            : `*${p.name}`;
        }
        const defaultVal = resolveDefault(p);
        return isSnippet
          ? `\${${currParam++}:${defaultVal}}`
          : `${p.name} = ${defaultVal}`;
      }
      case 'keyword':
        return isSnippet
          ? `${p.name}: \${${currParam++}:${resolveDefault(p)}}`
          : `${p.name}: ${resolveDefault(p)}`;
      default:
        return null;
    }
  });
  const filtered = filter(params, p => p !== null).join(', ');
  const blockParam = find(method.params, p => p.type === 'block');
  const parts = [method.name];
  if (!isEmpty(method.params)) parts.push(`(${filtered})`);
  if (blockParam) parts.push(` ${blockParam.schema}`);
  return parts.join('');
};

export const parseDocs = cache => {
  // Do nothing if the editor is not being used for templates
  if (!cache) return;

  const langTools = ace.acequire('ace/ext/language_tools');
  // Custom basic snippets
  /* eslint-disable */
  let completions = [
    {
      caption: '<%',
      snippet: '<% ${1:code} %>',
      tooltip: 'Executes code, but does not insert a value\n\n<% code %>',
      meta: 'erb',
    },
    {
      caption: '<%=',
      snippet: '<%= ${1:expression} %>',
      tooltip: 'Inserts the value of an expression\n\n<%= expression %>',
      meta: 'erb',
    },
    {
      caption: '<%-',
      snippet: '<% ${1:code} -%>',
      tooltip:
        'Executes code, but does not insert a value, trims the following line break\n\n<% code -%>',
      meta: 'erb',
    },
    {
      caption: '<%=-',
      snippet: '<%= ${1:expression} -%>',
      tooltip:
        'Inserts the value of an expression, trims the following line break\n\n<%= expression -%>',
      meta: 'erb',
    },
    {
      caption: '<%#',
      snippet: '<%# ${1:comment} -%>',
      tooltip:
        'Comment, removed from the final output, trims the following line break\n\n<%# comment -%>',
      meta: 'erb',
    },
  ];
  /* eslint-enable */
  // Parse JSON with DSL documentation
  forEach(JSON.parse(cache).docs.classes, cls => {
    const macros = cls.methods.map(method => ({
      caption: method.name,
      snippet: methodSignature(method, true),
      tooltip: methodTooltip(method, true),
      meta: 'macro',
    }));
    const props = cls.properties.map(prop => ({
      caption: `${cls.name}#${prop.name}`,
      snippet: methodSignature(prop, true),
      tooltip: methodTooltip(prop),
      meta: 'property',
    }));
    completions = concat(completions, macros, props);
  });
  const completer = {
    getDocTooltip: selected => selected.tooltip,
    getCompletions: (editor, session, pos, prefix, callback) =>
      callback(null, sortBy(completions, ['meta', 'caption'])),
  };

  langTools.setCompleters([completer]);
};
