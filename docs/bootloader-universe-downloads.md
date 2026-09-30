# Managed bootloader universe downloads

Implemented design for Foreman issue #39794. The feature spans Foreman,
Katello, and Smart Proxy. Archive extraction is provided by the Smart Proxy
TFTP API; Foreman supplies the operating system recipes, source selection,
dispatch, and host-build integration.

## Purpose and user flow

An administrator chooses one operating system and one content source, then
requests its boot files on TFTP Smart Proxies. Foreman builds source URLs and
destination paths. The proxies download archives or files, extract bootloaders,
and populate their `bootloader-universe/pxegrub2/` directories. Later, normal
host TFTP setup links those files into `host-config/<MAC>/grub2/`.

1. Associate an Installation Medium and an `x86_64` architecture with the OS,
   or select a compatible Katello Kickstart repository when Katello is installed.
2. On the Operating Systems index, choose **Sync boot files from <medium
   name>**. The action sends the request to every available, capable TFTP proxy.
   Katello adds a repository choice to the same dropdown.
3. Foreman reports which proxy requests were accepted. The administrator runs
   this action ahead of provisioning; acceptance does not mean the files have
   finished downloading.
   Before sending universe requests, Foreman checks HTTP source URLs with a
   HEAD request. An unsuccessful check produces a warning with the URL but does
   not prevent the proxy request. HTTPS and other source URLs are not checked.
4. For a supported PXEGrub2 UEFI build, Foreman renders the prefetched kernel
   and initramdisk paths from the universe and sends their expected archive
   source to every serving TFTP proxy. Each proxy waits for an active
   extraction, validates the files, and links the EFI, kernel, and initramdisk
   files into the host's `host-config/<MAC>/grub2/` directory. If the files
   are absent or belong to a different source, host setup returns HTTP 409.
   The host-build error in Foreman's UI directs the user to
   **Hosts > Provisioning Setup > Operating Systems** to run the download
   action for that OS and source, then retry.

OS creation, OS edits, fact imports, and host creation do not trigger this
operation. No Foreman background job, download-status database table, or
automatic choice among multiple media is introduced. For an x86_64 host using
PXEGrub2 UEFI and proxies with the `bootloader_universe_boot_files` capability,
host build mode uses the prefetched universe kernel and initramdisk and queues
no host-time boot-file fetch. Other boot paths retain the existing fetch.

## Source selection

### Foreman Installation Medium

The request identifies a single `Medium` already associated with the selected
OS. One request never combines several associated media. For each supported OS
architecture, Foreman interpolates the medium URL using the existing variables
`$arch`, `$major`, `$minor`, `$version`, and `$release`, then appends that OS
recipe's fixed suffix. The family recipe may convert the *source* architecture
name; the universe destination always uses the Foreman architecture name.

Add nullable `media.boot_path` (label **BootPath**) for an alternative URL
prefix used by this new operation. `Medium#boot_file_source_path` (or an
equivalent named helper) returns `boot_path.presence || path`. It does not
change the medium's regular `path`, host provisioning URLs, or the legacy
`pxe_prefix`/`unique_id` calculation. In universe mode, Ubuntu's installer ISO
URL is taken from the BootPath recipe as well. For a proxy using the legacy fallback,
keep the current kernel/initramdisk URLs and `boot/` destinations so they match
the paths generated for hosts.

BootPath accepts HTTP, HTTPS, or FTP URL prefixes and the same variables as
Path. It is blank by default. Validate it as a URL prefix without a query or
fragment; reject an NFS-only effective prefix for archive recipes because the
proxy's archive downloader supports URL downloads. Join prefix and suffix with
one slash while preserving the prefix's path. Do not use `URI.join` in a way
that discards the last prefix component.

Expose BootPath in the Installation Media create/edit form, strong parameters,
API create/update documentation, and API list/show representations. Seed the
standard **Ubuntu mirror** medium with:

```text
Path:     http://archive.ubuntu.com/ubuntu
BootPath: https://releases.ubuntu.com
```

On an existing installation, fill a blank BootPath only for an unmodified
medium named `Ubuntu mirror` whose Path still equals the seeded Path. Preserve
any custom Path or BootPath. Other seeded and user-created media keep a blank
BootPath unless an administrator sets one.

### Katello managed content

Katello can provision a Redhat-family OS from a Kickstart repository without
associating a Foreman Medium. The repository and its content source are an
explicit alternative source type for the same download operation. The Katello
integration resolves and authorizes the repository, checks
`distribution_bootable`, `distribution_arch`, and `distribution_version`, and
uses the published URL from `Katello::Repository#full_path(content_source,
true)`, as `ManagedContentMediumProvider#medium_uri` already does. BootPath
does not apply to this source.

A Katello repository has one distribution architecture, so one repository
request produces one OS/architecture recipe. It must match a supported
architecture associated with the OS. Match the repository family/name and
version to the selected OS using Katello's existing Kickstart compatibility
rules; a repository for a different OS or release is rejected. Validate that
the selected content source has the Pulp feature and publishes the selected
repository. Actual network reachability is checked by the target proxy. The
content source supplies bytes; the TFTP proxy IDs identify destinations and
may be different proxies.

Katello contributes source resolution and its UI selector through plugin
extensions. Foreman owns the generic dispatcher, proxy selection, and OS
recipes. An ordinary associated Medium remains available when Katello is
installed; an explicit Katello selection uses the selected repository and
content source.

The current Smart Proxy HTTP downloader accepts a URL but no Katello client
certificate. The Katello path used here must therefore be reachable from the
selected TFTP proxy as published HTTP content. If a deployment restricts that
path with client authentication, the implementation needs an authenticated
proxy fetch mechanism before claiming support for that deployment; do not put
certificates into the request URL or logs.

## Foreman API contract

Add `POST /api/operatingsystems/:id/download_boot_files` to API v2. Examples:

```json
{
  "source": { "type": "medium", "id": 42 },
  "smart_proxy_ids": [3, 7]
}
```

```json
{
  "source": {
    "type": "katello_kickstart_repository",
    "id": 123,
    "content_source_id": 9
  },
  "smart_proxy_ids": [3, 7]
}
```

`source` is required. The Katello source type is available only with Katello
installed. `smart_proxy_ids` is optional. Omission means all visible TFTP
proxies with the required universe/archive capabilities in the user's taxonomy
context. A supplied array selects exactly those proxies, removes duplicate
IDs, and may include older TFTP proxies, which receive the legacy fallback.
An explicit empty array is invalid. Unknown, unauthorized, or non-TFTP proxy
IDs are rejected before dispatch. The API does not infer a proxy from a host
or subnet because this operation has no host.

Require permission to edit the OS, view the selected Medium or Katello
repository, and view each target proxy. Resolve these objects through their
authorized scopes and enforce taxonomy visibility. Validate the complete
request before sending anything: supported OS recipe, source relationship,
source URL, source architecture, and at least one usable target proxy.

The response identifies the source, OS, architecture, and outcome for every
proxy/architecture pair. For example:

```json
{
  "operatingsystem_id": 18,
  "source": { "type": "medium", "id": 42 },
  "results": [
    {
      "smart_proxy_id": 3,
      "architecture": "x86_64",
      "mode": "universe",
      "accepted": true,
      "request_count": 2
    },
    {
      "smart_proxy_id": 7,
      "architecture": "x86_64",
      "mode": "legacy",
      "accepted": false,
      "error": "Proxy request failed"
    }
  ]
}
```

`request_count` is the number of proxy fetch calls accepted for that result;
Ubuntu needs two. `accepted` is true only if all calls for that
proxy/architecture pair were accepted. HTTP 202 means at least one proxy fetch
call was accepted, including partial dispatch. If none was accepted, return
502 with the per-proxy errors. Invalid selections return 422, and normal
authentication/authorization errors keep the API's existing semantics. No API
response claims that downloaded files are ready.

Keep the existing deprecated `GET /operatingsystems/:id/bootfiles` as a
read-only listing; the new POST is the only explicit download trigger.

## Operating Systems index UI

Add one dropdown item **Sync boot files from <medium name>** per associated
and visible Installation Medium. Clicking it POSTs the OS ID and that exact
medium ID to a Foreman HTML action without `smart_proxy_ids`, then shows the
accepted/error summary. The HTML action and public API call the same
dispatcher. The UI sends to all available capable proxies; it does not offer
a proxy picker. Hide or disable the action when there is no supported
architecture or no capable TFTP proxy. Show it only to a user who may invoke
the API and read that medium.

With Katello installed, **Sync boot files from Katello repository…**
appears in the same dropdown. It opens a server-rendered form with a readable,
compatible, bootable Kickstart repository selector and a content-source
selector, then sends the second API shape. Server-side validation confirms
that the selected source serves the repository. An OS index row has no
content-view or lifecycle-environment context, so the UI does not guess a
repository. Foreman exposes helper extension points for Katello's action and
source form.

The UI does not run on OS save. Keep regular edit, clone, and delete actions.
Use the same dispatcher from the HTML action and the API; do not duplicate URL
construction in JavaScript.

## Universe naming and host lookup

Use the values that Foreman already sends in
`Orchestration::TFTP#setTFTP` to name the destination:

```text
bootloader-universe/pxegrub2/<os.name.downcase>/<os.release>/<architecture.name>/
```

The proxy's `Pxegrub2#bootloader_path` checks that exact release directory,
then a `default` directory. `Pxegrub2#setup_bootloader` links each `*.efi`
file plus the recognized kernel and initramdisk names (`linux`, `initrd.gz`,
`vmlinuz`, `initrd.img`) found there into the host-specific GRUB directory.
It removes old links for those names when setting up the host again. The
proxy resolves universe aliases to their real EFI files before creating the
per-host links. The recipe supplies names that the proxy recognizes,
including `boot.efi` and, where available, `boot-sb.efi`.

The Debian and Ubuntu netboot GRUB binaries source a plain `grub.cfg` from
their embedded prefix. The proxy creates routing configurations at
`debian-installer/amd64/grub/grub.cfg` and `grub/grub.cfg`, selecting the
host's `grub2/grub.cfg-<MAC>` through GRUB's `net_default_mac`. The routing
supports both TFTP and the `/httpboot/` URL prefix and preserves existing
administrator-provided configurations. A plain `grub.cfg` link is also
created in each host's GRUB directory for binaries that use the EFI image's
directory as their prefix. These routes continue to select the current
host configuration after leaving build mode.

The universe directory name is intentionally independent of mirror naming.
Examples:

| Foreman host OS / architecture | Source naming | Universe key |
| --- | --- | --- |
| Debian 12 / `x86_64` | `bookworm`, `installer-amd64`, `debian-installer/amd64` | `debian/12/x86_64` |
| Ubuntu 26.04 / `x86_64` | `26.04`, `amd64` archive members | `ubuntu/26.04/x86_64` |
| CentOS_Stream 10 / `x86_64` | `10-stream/BaseOS/x86_64/os` | `centos_stream/10/x86_64` |

Do not force OS names or versions into the sample script's directory scheme.
Convert only source architecture names required by the archive or mirror.
This release supports Foreman's `x86_64` architecture, using `amd64` in Debian
and Ubuntu source paths and archive members. Other architectures need their
own verified source members and EFI filenames before they are offered.

## OS recipe contract

Add a method to `Operatingsystem` that returns no recipe by default. Implement
it in `Redhat` and `Debian`; `Debian` selects a separate Ubuntu recipe when
the OS name is Ubuntu. The method takes the chosen source prefix and
architecture and returns a list of proxy fetch requests. It does not start
network work, choose media, or choose proxies. Each request specifies one
exact TFTP destination and either a simple source URL or an `extract` hash.
Keep the fixed suffixes and archive-member maps in these OS family classes.

A plain Ruby method is sufficient; no separate interface framework is needed.
For example, the dispatcher can call
`os.bootloader_universe_requests(source_prefix: prefix, architecture: arch)`.
The base method returns an empty list to mean unsupported, and the family
methods return request hashes. The dispatcher rejects an empty list before
contacting a proxy.

For all recipes, `D` below is the universe directory above and `P` is the
interpolated BootPath-or-Path prefix, or the Katello published prefix. Send
the nested `extract` payload as JSON with `Content-Type: application/json`.
The current `ProxyAPI::Resource#post` sends form data, so extend
`ProxyAPI::TFTP` with a JSON fetch method while preserving its form-encoded
`fetch_boot_file(prefix:, path:)` callers.

The proxy contract maps each *destination* to an archive *member* in `files`,
and each symlink *path* to its target path in `symlinks`. For example, a
CentOS Stream 10 request with universe key `centos_stream/10/x86_64` sends:

```json
{
  "extract": {
    "source": "http://mirror.stream.centos.org/10-stream/BaseOS/x86_64/os/images/boot.iso",
    "destination": "bootloader-universe/pxegrub2/centos_stream/10/x86_64/boot.iso",
    "type": "iso",
    "files": {
      "bootloader-universe/pxegrub2/centos_stream/10/x86_64/grubx64.efi": "EFI/BOOT/grubx64.efi",
      "bootloader-universe/pxegrub2/centos_stream/10/x86_64/shimx64.efi": "EFI/BOOT/BOOTX64.EFI"
    },
    "symlinks": {
      "bootloader-universe/pxegrub2/centos_stream/10/x86_64/boot.efi": "bootloader-universe/pxegrub2/centos_stream/10/x86_64/grubx64.efi",
      "bootloader-universe/pxegrub2/centos_stream/10/x86_64/boot-sb.efi": "bootloader-universe/pxegrub2/centos_stream/10/x86_64/shimx64.efi"
    }
  }
}
```

The Ubuntu ISO is a second request with exact `source` and `destination`
fields, without `extract`. All proxy paths are relative to its TFTP root.

### Redhat family

One ISO extraction request:

```text
source:      P/images/boot.iso
archive:     D/boot.iso
type:        iso
members:     EFI/BOOT/grubx64.efi -> D/grubx64.efi
             EFI/BOOT/BOOTX64.EFI -> D/shimx64.efi
             images/pxeboot/vmlinuz -> D/vmlinuz
             images/pxeboot/initrd.img -> D/initrd.img
symlinks:    D/boot.efi -> D/grubx64.efi
             D/boot-sb.efi -> D/shimx64.efi
```

The Redhat recipe covers the Redhat OS family on `x86_64`, including the
CentOS Stream sample. It assumes a boot ISO with the listed member paths;
proxies report missing members in their logs. A Katello Kickstart repository
uses this recipe with its published repository URL as `P`.

### Debian

Require `release_name` for the source suffix. One TGZ extraction request:

```text
source:      P/dists/<release_name>/main/installer-amd64/current/images/netboot/netboot.tar.gz
archive:     D/netboot.tar.gz
type:        tgz
members:     debian-installer/amd64/linux -> D/linux
             debian-installer/amd64/initrd.gz -> D/initrd.gz
             debian-installer/amd64/grubx64.efi -> D/grubx64.efi
             debian-installer/amd64/bootnetx64.efi -> D/shimx64.efi
symlinks:    D/boot.efi -> D/grubx64.efi
             D/boot-sb.efi -> D/shimx64.efi
```

Debian's `bootnetx64.efi` is its network Shim loader. The recipe includes it
for Secure Boot, and host readiness requires both EFI aliases for every
supported recipe. `release_name` is used only in the URL; `os.release` is
used in `D`.

### Ubuntu

Use `os.release` in both source filenames and the universe directory. The
standard seeded medium uses `https://releases.ubuntu.com` as `P`. Send a TGZ
extraction request and a separate exact-file ISO download:

```text
source:      P/<release>/ubuntu-<release>-netboot-amd64.tar.gz
archive:     D/netboot.tar.gz
type:        tgz
members:     amd64/linux -> D/linux
             amd64/initrd -> D/initrd.gz
             amd64/grubx64.efi -> D/grubx64.efi
             amd64/bootx64.efi -> D/shimx64.efi
symlinks:    D/boot.efi -> D/grubx64.efi
             D/boot-sb.efi -> D/shimx64.efi

source:      P/<release>/ubuntu-<release>-live-server-amd64.iso
destination: D/boot.iso
```

The proxy retains both the netboot archive and the ISO. In universe mode,
the autoinstall template uses the ISO request's source URL, preserving its
scheme and BootPath prefix. This works with TFTP-only proxies: the installer
downloads the ISO directly from that source. The retained proxy copy can be
published separately, but is not assumed to be available over HTTP.
The archive-member
paths and file naming above follow `../smart-proxy/extra/download_test.sh`.
No new RPM or DEB extraction recipe is included in this first version.

## Proxy dispatch and compatibility

For universe mode, require the TFTP feature and capabilities
`bootloader_universe` and `bootloader_archive_iso`. Debian and Ubuntu also
require `bootloader_archive_tgz`. Use the capabilities recorded by Foreman for
each Smart Proxy; a proxy feature refresh is needed after a proxy upgrade.

| Selected proxy | Dispatch mode |
| --- | --- |
| TFTP and all capabilities required by the OS recipe | Universe archive/file requests |
| TFTP but missing a required capability, selected explicitly through the API | Existing kernel/initramdisk requests |
| No TFTP feature | Invalid selection |

The index UI omits proxies missing any required capability. The API accepts
an explicit selection of older proxies with TFTP and uses the existing
kernel/initramdisk `pxe_files` fetches under `boot/` for those proxies. That
fallback uses the selected source through its existing medium provider and
the existing `prefix`/`path` API fields. It never sends `extract` to an older
proxy. It creates no universe bootloader files, so the proxy's existing
default-bootloader behavior remains in use. A Katello source uses
`ManagedContentMediumProvider` for those legacy PXE URLs, with the selected
repository and content source supplied explicitly.

Foreman sends requests to proxies and collects immediate acceptance or
dispatch errors. The Smart Proxy's HTTP downloader starts regular file
downloads asynchronously; archive extraction runs in an asynchronous worker.
The proxy's `UNI_SYNC` registers archive output directories before returning.
Both host bootloader setup and prefetched-file validation wait for an active
extraction in that directory. This synchronization is process-local: a
multi-process proxy deployment cannot rely on the wait across processes.
No Foreman job waits for completion. The separate Ubuntu ISO fetch has no
`UNI_SYNC` wait and is not part of host-build readiness validation, so it
must finish before it is used.

The Smart Proxy HTTP downloader also performs a HEAD preflight for HTTP and
HTTPS sources by default, following redirects. Its
`tftp_http_download_preflight` setting can disable that check for servers
that do not support HEAD. This is separate from Foreman's advisory HTTP-only
HEAD warning: Foreman still sends a request after its warning, while a Smart
Proxy preflight failure can reject or fail the download.

### Host build using universe boot files

Redhat-family, Debian, and Ubuntu recipes include a kernel and initramdisk in
the universe. For a build-mode x86_64 host using PXEGrub2 UEFI, Foreman uses
those paths in the TFTP templates only when every TFTP proxy serving the host
advertises `bootloader_universe_boot_files` as well as the relevant extraction
capabilities. Foreman then omits the normal `setTFTPBootFiles` orchestration
task. If a proxy lacks the capability, the existing `boot/` download and
template paths remain in use on all serving proxies.

Set the `disable_universe` host parameter to a truthy value such as `true`,
`yes`, or `1` to force that same legacy path for an individual host.

Foreman derives the expected archive URL from the host's Installation Media
BootPath (or Path), or from its Katello Kickstart repository and content source.
It sends the archive path, kernel and initramdisk paths, and SHA-256 digest of
that URL with the existing TFTP `set` request. Before writing the host config,
the proxy checks the archive, its `.source` digest marker, kernel, initramdisk,
GRUB EFI file, required Shim EFI file, and EFI alias symlinks. The proxy
rejects missing or mismatched files with HTTP 409. Foreman surfaces this in
the host-build UI as: **Download boot files for Operating System '<OS>' from
Hosts > Provisioning Setup > Operating Systems. Select the source used by this
host, then retry the build.**

The rendered GRUB configuration refers to host-specific kernel and initramdisk
symlinks alongside the EFI links in `host-config/<MAC>/grub2/`.

The universe path holds one set of files per OS/release/architecture on each
proxy. A later request from another source targets the same paths. For archive
extraction, the proxy records a digest of the source URL beside the archive
and bypasses its conditional HTTP download when the source changes. Exact-file
downloads also bypass the conditional check, so a selected ISO replaces the
one already at that destination. Operators
should not submit two different sources for the same destination concurrently:
the current proxy archive lock may skip an overlapping request. A repeat after
the first operation finishes updates files according to the proxy's normal
download behavior. The API/UI need not track provenance or completion for
this version; provenance and collision handling can be extended if operational
use shows the explicit source selection is insufficient.

## Errors and operational limits

Validate malformed or unsupported requests before dispatch. Report HTTP/API
failures for individual proxies to the caller, without rolling back accepted
requests on other proxies. Downloads or extractions that fail after proxy
acceptance are diagnosed in the Smart Proxy log; adding completion polling,
retry orchestration, or extraction-failure reporting to Foreman is outside
this work. A failed extraction can leave a partially populated universe
directory. The proxy removes the old source marker before replacing any
extracted files and restores it only after complete extraction and symlink
creation. Readiness rejects that directory after a failed extraction, even
for the previous source; retrying the download repairs it. An accepted
request is never presented as boot readiness.

The proxy accepts exact `source`/`destination` and nested `extract` requests.
It also refreshes output when the source changes, allows repeat extraction
over existing EFI aliases, validates prefetched files during host setup, and
resolves EFI aliases when making host links. Foreman's destination naming
matches the proxy's existing OS/release/architecture lookup.

## Implementation locations

| Repository | Implemented changes |
| --- | --- |
| `foreman` | Nullable `media.boot_path` migration, Medium validation/helper, form/API fields, Ubuntu seed update, OS family recipes, `ProxyAPI::TFTP` JSON requests, dispatcher, API and HTML actions, index dropdown, HTTP warning, source-aware host-build template paths, orchestration, and UI readiness error. |
| `katello` | Explicit Kickstart repository source resolver and authorization, compatible repository/content-source selection, plugin UI action and form, legacy provider construction. |
| `smart-proxy` | Archive extraction capabilities and API, asynchronous downloads, HTTP preflight, `UNI_SYNC`, source-marker refresh, repeat extraction over EFI aliases, per-host EFI alias resolution and kernel/initramdisk links, prefetched-file validation, and `bootloader_universe_boot_files` capability. |

The feature commits use issue `#39794`.

## Acceptance criteria

1. A user can set, read, update, and clear BootPath in the Installation Media
   UI and API. A new medium defaults to blank. Seeded Ubuntu mirror obtains
   `https://releases.ubuntu.com` without overwriting customized media.
2. An OS index row offers a separate action for each associated, visible
   medium. Saving an OS or importing facts sends no download request.
3. The API accepts one explicit medium and optional TFTP proxy IDs. The UI
   targets all capable proxies; an explicitly selected older TFTP proxy gets
   the current kernel/initramdisk fallback.
4. With Katello installed, an associated Foreman Medium still works. A
   compatible published Kickstart repository can also be selected explicitly,
   including a content source, without requiring a Foreman Medium association.
5. On a capable proxy, an `x86_64` Redhat, Debian, or Ubuntu request sends the
   exact archive/file requests above. The destination uses the same OS name,
   release, and architecture as Foreman's host TFTP setup.
6. A host configured while extraction is active uses the proxy's existing
   synchronization and symlink lookup within the supported proxy process
   model. API/UI responses describe dispatch acceptance and per-proxy errors,
   without claiming file completion.
7. Unsupported OS families, unsupported architectures, invalid source
   associations, unauthorized sources/proxies, and an empty explicit proxy
   list fail before any proxy receives a request. Proxy dispatch failures
   after validation are reported for each attempted proxy/architecture pair.
8. A supported PXEGrub2 UEFI host uses universe kernel/initramdisk paths and
   queues no boot-file fetch when all serving proxies support host universe
   validation. The proxy links these files into the host-specific GRUB
   directory. Missing or mismatched files return HTTP 409 and fail host setup
   with a UI message naming **Hosts > Provisioning Setup > Operating Systems**
   and its source-specific download action. Older proxies keep the existing
   host-time download behavior.

## Manual UEFI PXE smoke test

After downloading the OS files and rebuilding a host's TFTP configuration,
run the Smart Proxy checkout's `extra/pxe_vm_test.sh <MAC> /tmp/tftproot`.
The launcher uses QEMU's private DHCP/TFTP server to serve the existing
directory, and writes serial output and a packet capture to a temporary
directory. Set `PXE_VM_DISPLAY=none` for headless operation; the QEMU monitor
accepts `screendump /tmp/pxe.ppm` and `quit`.

The VM includes `virtio-rng-pci`: current OVMF network drivers depend on
`EFI_RNG_PROTOCOL`. Without a guest RNG, the default emulated CPU can leave
OVMF with no network boot option and no DHCP/TFTP traffic. The launcher also
uses `-cpu max` for the instruction set needed by CentOS Stream 10.

This checks ordinary UEFI, GRUB configuration lookup, and kernel/initrd
startup. The VM has no disk and its networking is isolated, so it does not
test a complete installation or Secure Boot enforcement. On the reviewed
Debian 12 and CentOS Stream 10 downloads, the test reached the Debian
installer and the CentOS dracut environment respectively.

## References

- [Foreman bootloader universe documentation](https://docs.theforeman.org/nightly/Provisioning_Hosts/index-foreman-el.html#grub2-uefi-boot-loader-and-the-bootloader-universe-structure)
- [Strict Secure Boot and HTTPS provisioning discussion](https://community.theforeman.org/t/strict-secureboot-https-provisioning-of-bare-metal-and-vms/45983)
- Smart Proxy examples: `../smart-proxy/extra/download_test.sh`

## Open Questions

- With Katello installed, the repository URL comes from
  `Katello::Repository#full_path(content_source, true)`, so Smart Proxies
  download boot files over HTTP. The ultimate goal is HTTPS downloads. How
  should the proxy authenticate to Katello content over HTTPS without exposing
  credentials in the fetch request or logs?

## Checks already made for source URLs

HEAD requests with redirects on 2026-09-30 returned 200 for the seeded
CentOS Stream 10 `images/boot.iso` URL and the seeded Debian `bookworm`
netboot archive URL. The seeded Ubuntu `archive.ubuntu.com/ubuntu` prefix
returned 404 for the example 26.04 netboot archive and live-server ISO;
`https://releases.ubuntu.com/26.04/` returned 200 for both. These checks
establish URL reachability for those examples, not archive contents, other
releases, or deployment-specific Katello Pulp access.
