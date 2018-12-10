const { spawn: _spawn, spawnSync: _spawnSync } = require('child_process');

const run = action => ({
  command,
  commandArgs = [],
  cwd = null,
  env = process.env,
  stdio = 'inherit',
}) => {
  // eslint-disable-next-line no-console
  console.log(
    `${cwd ? `cd ${cwd} && ` : ''}${command} ${commandArgs.join(' ')}`
  );

  action(command, commandArgs, { cwd, env, stdio });
};

module.exports = {
  spawn: run(_spawn),
  spawnSync: run(_spawnSync),
};
