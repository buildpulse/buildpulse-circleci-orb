<a href="https://buildpulse.io"><img src=".github/banner.svg" alt="buildpulse-circleci-orb, by BuildPulse" width="100%"></a>

<a href="https://buildpulse.io/products/flaky-tests?ref=github-badge"><img src=".github/runs-on-buildpulse-compact.svg" alt="Runs on BuildPulse" height="28"></a>

Easily connect your CircleCI jobs to [BuildPulse](https://buildpulse.io) to help you optimize [CI runners](https://buildpulse.io/products/runners) and find / [fix flaky tests](https://buildpulse.io/products/flaky-tests).

## Usage

See [this orb's listing in CircleCI's Orbs Registry](https://circleci.com/orbs/registry/orb/workshop64/buildpulse) for details on usage, or see the example below.

## BuildPulse Cache Example

In this example `config.yml` snippet, after your tests run, the `buildpulse/upload` command sends the test results to BuildPulse for analysis.

```yaml
version: 2.1

orbs:
  buildpulse: workshop64/buildpulse@x.y

jobs:
  build:
    docker:
      - image: cimg/<some-docker-image>

    steps:
      - checkout

      - buildpulse/restore_cache:
          key: yarn-packages-{{ checksum "yarn.lock" }}
          paths: ./node_modules ./generated_assets

      - run: echo "Run your tests and generate XML reports for your test results"

      - buildpulse/save_cache:
          key: yarn-packages-{{ checksum "yarn.lock" }}
          paths: ./node_modules ./generated_assets

      - buildpulse/upload:
          account-id: 123
          repository-id: 123
          path: ./spec/reports
          access-key-id: BUILDPULSE_ACCESS_KEY_ID
          secret-access-key: BUILDPULSE_SECRET_ACCESS_KEY
          path: test/reports # path to JUnit XML file
          account-id: <buildpulse-account-id>
          repository-id: <buildpulse-repository-id>
          coverage-files: ./coverage/lcov/project.lcov # optional
          tags: tag1 tag2 tag3 # optional

workflows:
  version: 2
  commit:
    jobs:
      - build
```


## CI Analytics Example

In this example `config.yml` snippet, after your tests run, the `buildpulse/upload` command sends the test results to BuildPulse for analysis.

```yaml
version: 2.1

orbs:
  buildpulse: workshop64/buildpulse@x.y

jobs:
  build:
    docker:
      - image: cimg/<some-docker-image>

    steps:
      - checkout

      - run: echo "Run your tests and generate XML reports for your test results"

      - buildpulse/upload:
          account-id: 123
          repository-id: 123
          path: ./spec/reports
          access-key-id: BUILDPULSE_ACCESS_KEY_ID
          secret-access-key: BUILDPULSE_SECRET_ACCESS_KEY
          path: test/reports # path to JUnit XML file
          account-id: <buildpulse-account-id>
          repository-id: <buildpulse-repository-id>
          coverage-files: ./coverage/lcov/project.lcov # optional
          tags: tag1 tag2 tag3 # optional

workflows:
  version: 2
  commit:
    jobs:
      - build
```
