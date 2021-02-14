# BuildPulse CircleCI Orb [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/workshop64/buildpulse)](https://circleci.com/orbs/registry/orb/workshop64/buildpulse) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/Workshop64/buildpulse-circleci-orb/master/LICENSE)

Easily connect your CircleCI jobs to [BuildPulse](https://buildpulse.io) to help you identify and eliminate flaky tests.

## Usage

See [this orb's listing in CircleCI's Orbs Registry](https://circleci.com/orbs/registry/orb/workshop64/buildpulse) for details on usage, or see the example below.

## Example

In this example `config.yml` snippet, the `buildpulse/setup` command installs the BuildPulse uploader and identifies the environment variables that contain the required BuildPulse secrets (Access Key ID and Secret Access Key). Then, after your tests run, the `buildpulse/upload` command sends the test results to BuildPulse for analysis.

```yaml
version: 2.1

orbs:
  buildpulse: workshop64/buildpulse@x.y

jobs:
  build:
    docker:
      - image: circleci/<some-docker-image>

    steps:
      - checkout

      - run: echo "Run your tests and generate XML reports for your test results"

      - buildpulse/upload:
          path: test/reports
          account-id: <buildpulse-account-id>
          repository-id: <buildpulse-repository-id>

workflows:
  version: 2
  commit:
    jobs:
      - build
```
