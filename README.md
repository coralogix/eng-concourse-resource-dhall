# Dhall Concourse Resource Type

[![Docker Repository on Quay](https://quay.io/repository/coralogix/eng-concourse-resource-dhall/status "Docker Repository on Quay")](https://quay.io/repository/coralogix/eng-concourse-resource-dhall)

A Concourse resource for fetching remote Dhall expressions.

While this resource will technically work with Dhall expressions that do not include remote imports, such expressions have constant hashes and it rather defeats the purpose of having a Concourse resource to track changes.

## Recommended Usage

Because Dhall's performance is highly dependent upon the presence of a warm cache, you are recommended to extend this image with one that already has a warmed cache of the libraries which you use.

In other words, you should build a custom image with, e.g. (note: you cannot use `<<<` in a `Dockerfile`, that's the reason for the piped `echo` call):

```Dockerfile
FROM quay.io/coralogix/eng-concourse-resource-dhall:v1.39.0

RUN set -ex; \
    echo 'https://raw.githubusercontent.com/dhall-lang/dhall-lang/v16.0.0/Prelude/package.dhall' | dhall >/dev/null ; \
    echo 'https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/v4.0.0/package.dhall'    | dhall >/dev/null ; \
    echo 'https://raw.githubusercontent.com/coralogix/dhall-kops/v0.6.3/package.dhall'           | dhall >/dev/null
```

and use that image instead in the source for the `resource_types`.

## Source Configuration
* `expression` : _Required_ (`string`). A Dhall expression that is fed directly to the `dhall` executable, e.g. `{ foo = "bar" }`
* `ascii` : _Optional_ (`bool`). Wheter to pass the `--ascii` flag to the `dhall` executable. Defaults to `false`.
* `censor` : _Optional_ (`bool`). Whether to pass the `--censor` flag to the `dhall` executable. Defaults to `false`.
* `explain` : _Optional_ (`bool`). Whether to pass the `--explain` flag to the `dhall` executable. Defaults to `false`.
* `skip_validation` : _Optional_ (`bool`). Whether to pass the validation on the get step. Defaults to `true`.
* `environment_variables` : _Optional_ (`object`). Adds the included environment variables when running the `dhall` executable. See example usage below.

### Example Usage

Resource type definition

```yaml
resource_types:
- name: dhall
  type: registry-image
  source:
    repository: quay.io/coralogix/eng-concourse-resource-dhall
    tag: v1.39.0
```

Fetching the latest Prelude

```yaml
resources:
- name: dhall-prelude
  type: dhall
  source:
    expression: https://prelude.dhall-lang.org/package.dhall
```

Fetching a sensitive configuration from a private GitHub repository

```yaml
resources:
- name: sensitive-configuration
  type: dhall
  source:
    expression: |
      let Config = { private : Text }
      in https://raw.githubusercontent.com/myorg/myrepo/master/config.dhall
           using
           ( toMap
               { Authorization =
                   "token ${env:GITHUB_TOKEN as Text}"
               }
           ) : Config
    censor: true
    environment_variables:
      GITHUB_TOKEN: "((github-token))"
```

## Behavior

### `check` : Check for a change in the Dhall expression
The Dhall expression is evaluated and its hash is retrieved as this resource's version. There are no parameters.

### `in` : Fetch the Dhall expression
The Dhall expression is evaluated into normal form and output into the resource's directory as `normal.dhall`. There are no parameters.

### `out` : Not supported

## Maintainers
[Ari Becker](https://github.com/ari-becker)
[Oded David](https://github.com/oded-dd)

## License
[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) © Coralogix, Inc.
