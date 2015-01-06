# Modularization

-   Stack is not connected to any existing Foreman models to allow sharing.
-   ParameterResource defines inputs and outputs through parameters to avoid
    entanglement between stacks.
-   ConnectParameterResource connects parameters between child stacks in a given
    parent.
-   See example stack.

# Parameters

-   User edits parameters on hostgroups (created based on `ParameterResource`,
    stored in `GroupParameter` or `DeploymentParameter`).
-   Those parameters are applied to puppet class parameters with
    overrides (`ParameterOverrideResource`).
-   `ParameterOverrideResource` can define use only `ParameterResources` from same stack.
-   If `ParameterOverrideResource` does not have a value defined, than it has to be also
    provided on deployment configuration.

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

# Implementation notes

-   `ParameterOverrideResource`'s optional value could be also done with children as it's
    with `ParameterResource`.
