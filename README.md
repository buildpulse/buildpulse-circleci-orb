# BuildPulse CircleCI Orb [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/Workshop64/buildpulse-circleci-orb/master/LICENSE)

Easily send test results to [BuildPulse](https://buildpulse.io) from your CircleCI jobs.

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

      # 📣 Be sure to execute this step *before* running your tests
      - buildpulse/setup:
          access-key-id: BUILDPULSE_ACCESS_KEY_ID
          secret-access-key: BUILDPULSE_SECRET_ACCESS_KEY

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
