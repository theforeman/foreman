# Registries

This directory is configured in `autoload_once_paths`, so its contents will
only ever be loaded once by Rails. This is designed for objects with
class-level data that's set up and appended to during app initialisation.

Keep the contents of this directory as small as possible, so as much of the
application as possible may be autoloaded in development.

## Plugins

For example, when extending the plugin interface, prefer to store data in
the existing `Foreman::Plugin` registry and access it via
`Foreman::Plugin.all.map(&:foo)`. This avoids creating a new registry class.

## Other registries

Internal-only registries can be safely put into app/services/ under the full
autoloader if they lazily populate data or populate on load, rather than being
populated from a Rails initialiser.
