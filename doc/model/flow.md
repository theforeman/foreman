# Deployment flow

_If user is not mentioned then the step is done automatically._

## Deployment creation

-   Show Deployment form to **User**.
-   **User** picks the stacks to deploy
-   **User** inputs name and description.
-   **User** submits the form.
-   Deployment is created.

## Deployment configuration

**User** creates required resources one by one.

-   **User** assigns existing foreman `Subnet`s with `SubnetTypesResource`s.
-   **User** Starts by creating all the `Hostgroup`s for each `HostgroupResource`.
    (Custom form allowing to select just items bellow.)
    -   If parent is not `HostgroupResource`, it needs to provided by **user**.
    -   `Hostgroup` inherits configuration from parent, remaining options
        are provided by **user**.
    -   `Hostgroup` is created.
    -   `ParameterResources` adds the parameters to the hostgroup (implemented with
        `GroupParameter`) or to `Deployment` (implemented with `DeploymentParameter`)
        if there is no `HostgroupResource` associated on `ParameterResource`.
        -   Only if there is no parameter with that name already configured through parent `Hostgroup`.
        -   `ConnectParameterResources` are applied if any.
    -   `PuppetClass`es are looked up by `PuppetClassResource`s.
    -   `ParameterOverrideResource`s overrides defined puppet class parameters by defined value
        in the resource.
        -   If there is no value defined and the value is already configured through different matcher
            then the value is used and new override is not created.
-   **User** configures remaining unconfigured parameters added to `Hostgroup`.
-   **User** continues by creating all the `Hosts` for each `HostResource`.
    (Custom form allowing to select just items bellow.)
    -   **User** assigns `Subnet`s to subnet types,
    -   picks `ComputeResource` based on allow-list defined by
        `ComputeResourceResource`s.
    -   **User** selects provisioning (true is default) (Some managed hosts may be
        just reused without provisioning).
    -   **User** defines number of the `Host`s required within `min`, `max`
        defined on `HostResource`.
        -   Bare metal hosts are assigned if applicable.
    -   `Host`s are created or if already existing just assigned to proper
        `Hostgroup`.
    -   Provisioning may already start if it cannot be delayed. But the
        puppetrun has to be always delayed, it's orchestrated later.
-   All hosts are just created waiting for provisioning or only provisioned
    without configuration triggered.

## Deployment

**User** triggers deployment.

-   All hosts are provisioned if required.
-   Waits until all hosts are provisioned.
-   Orchestration of the `Ordered` resources. e.g.:
    -   Puppetrun an all controller nodes in parallel,
    -   then puppetrun on all compute nodes in parallel.
