# Modularization

-   Stack is not connected to any existing Foreman models to allow sharing.
-   ParamResource defines inputs and outputs through parameters to avoid
    entanglement between stacks.
-   ConnectParamResource connects parameters between child stacks in a given
    parent.
-   See example stack.

# Conventions

-   User edits parameters on hostgroups (created based on `ParamResource`,
    stored in `HostgroupParameter`).
-   Those parameters are applied to puppet class parameters with
    overrides (`ParamOverrideResource`).
-   `ParamOverrideResource` can define use only `ParamResources` from same stack.

# Networking

-   For now provisioning `Subnet` is assumed to be configured on `Hostgroup` which
    propagates it to its `Host`s.

# JSON format

-   Simple flat export of data, see `export.json`.
-   That can be extended later to be more user-friendly by nesting and by naming
    associations based on purpose not by type, see `friendly.json`.
-   Other option is to write a simple Ruby DSL to generate the json file. Can be added later.
    (I think this is better than `friendly.json`.) See `dsl.rb`.

# Q&A

-   Different config management tools?

    _Should not be too difficult, can be done by replacing few puppet specific resources
    with a chef resources._
