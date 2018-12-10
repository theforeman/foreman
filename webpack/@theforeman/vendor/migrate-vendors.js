#!/usr/bin/env node

/* eslint-disable no-console, no-await-in-loop */
const util = require('util');
const fs = require('fs');
const _glob = require('glob');

const defaultGlobStr = './webpack/**/*.js';

const migrations = require('./migrations');

const glob = util.promisify(_glob);
const readFile = util.promisify(fs.readFile);
const writeFile = util.promisify(fs.writeFile);

const getArgs = () => {
  const [globStr = defaultGlobStr] = process.argv.slice(2);

  return {
    globStr,
  };
};

const migrateText = text => {
  let replaceText = text;

  migrations.forEach(migration => {
    replaceText = replaceText.replace(
      migration.originalStringOrRegex,
      migration.replacementString
    );
  });

  return replaceText;
};

const run = async () => {
  try {
    console.log('Updating vendors...');

    const { globStr } = getArgs();

    const files = await glob(globStr);

    for (const file of files) {
      const text = await readFile(file, 'utf8');
      const migratedText = migrateText(text);

      if (text !== migratedText) {
        await writeFile(file, migratedText, 'utf8');

        console.log(`UPDATED: ${file}`);
      }
    }
  } catch (error) {
    console.error(error);
    process.exit(-1);
  }
};

run();
