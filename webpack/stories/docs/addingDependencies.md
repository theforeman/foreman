
# Adding or updating NPM dependencies

The easiest way of adding dependencies into [package.json](https://github.com/theforeman/foreman/blob/develop/package.json) is executing `npm install` with `--save` or `--save-dev` for devel dependencies:
```
npm install --save <pkg>@<version>
npm install --save-dev <pkg>@<version>
```
That will automatically edit pacakge.json at correct places for you.

### Packaging

The Foreman distributes npm dependencies in separate rpm files. Therefore you have to make sure the new dependency is packaged as rpm. You can find the instructions about how to create an rpm from an npm packge in the [foreman-packaging](https://github.com/theforeman/foreman-packaging/tree/rpm/develop#adding-npm-packages) repo.

**Watch out:** adding/updating npm dependencies is currently very frequent source of errors. There's a check on Github that won't let you merge a PR that touches package.json unless the packaging team approves the change, but it's good to be careful in this area. More details in the following section.

### Troubleshooting

Since npm packages are installed from rpms in production, and the nature of both packaging systems is a bit different, issues can occur quite frequently. Rpm allows only one package version to be installed on a system (if we don't take scl into account) while npm supports multiple versions of one pacakge. Mapping both systems on each other therefore isn't trivial.

It can happen that you change version of a Foreman's direct dependency and it silently breaks some other npm package (or plugin) that depended on it too. It usually results in nightlies with completely broken js functionality. This is tricky, because develop continues working normally. In such cases it's helpful to use the [update_npm_dependencies.rb](https://github.com/theforeman/foreman-packaging/pull/2627) script that can help you with updating all packages to the correct versions.
