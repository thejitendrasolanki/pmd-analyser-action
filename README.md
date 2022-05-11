# pmd-analyser-action
[![PMD Static Code Analysis](https://github.com/thejitendrasolanki/pmd-analyser-action/actions/workflows/main.yml/badge.svg)](https://github.com/thejitendrasolanki/pmd-analyser-action/actions/workflows/main.yml)

GitHub Action to run [PMD Analyser](https://pmd.github.io/) based on the ruleset defined. This action generates a SARIF report which can be uploaded to GitHub.

Features of this action include:

- Set the severity level you want rules reported at. Levels include error, warning and note (default level is warning).
- Run PMD Analyser on the files changed. File comparison can be done either based on a git diff or based on the files changed specified on the GitHub pull request.

Note that when you are running this action and making use of the SARIF uploader in the example below, if you are looking to get pull request comments then you will need to run the analyser on push events for the target branch that pull requests are targetting. Also note that the PMD analyser needs to be run in the same workflow file, as GitHub's upload SARIF action also checks both the commits and the workflow file they were run from. It's recommended you run a full analysis when pushing on the main branch and an incremental on pull requests (as if you run an incremental on push, it assumes that you may have fixed some errors).

## Example GitHub Action Workflow File
```
name: PMD Static Code Analysis
on:
  pull_request:
    branches:
      - main
  push:
    branches:
      - main
    paths:
      - 'action/**'
      - 'pmd-rulesets/**'
      - 'src/**'
      - 'pmd-analyser.sh'
  workflow_dispatch:

jobs:
  pmd-analyser-check:
    name: PMD Static Code Analysis
    permissions:
      security-events: write
      actions: read
      contents: read
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v2
        with:
          # Incremental diffs require fetch depth to be at 0 to grab the target branch
          fetch-depth: '0'
      - name: Run Full PMD Analysis
        if: github.event_name == 'push' || github.event_name == 'workflow_dispatch'
        id: pmd-full-analysis
        uses: ./actions
        with:
          analyse-all-code: 'true'
          pmd-version: 'latest'
          file-path: './src'
          rules-path: './pmd-rulesets/apexAllRuleSet.xml'
          error-rules: 'AvoidDirectAccessTriggerMap,AvoidDmlStatementsInLoops,AvoidHardcodingId'
          note-rules: 'ApexDoc'
      - name: Run PMD Analysis on Files Changed
        id: pmd-partial-analysis
        if: github.event.pull_request != null
        uses: ./actions
        with:
          pmd-version: 'latest'
          file-path: './src'
          rules-path: './pmd-rulesets/apexAllRuleSet.xml'
          error-rules: 'AvoidDirectAccessTriggerMap,AvoidDmlStatementsInLoops,AvoidHardcodingId'
          note-rules: 'ApexDoc'
      - name: Upload results to GitHub
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: pmd-output.sarif
      - name: SARIF Multitool
        uses: microsoft/sarif-actions@v0.1
        with:
          # Command to be sent to SARIF Multitool
          command: 'validate pmd-output.sarif'
      - name: No PMD Errors?
        run: |
          if ${{ steps.pmd-full-analysis.outputs.error-found }} ${{ steps.pmd-partial-analysis.outputs.error-found }}
          then
            exit 3
          fi

```

## Inputs

### analyse-all-code

Used to determine whether you just want to analyse the files changed or the whole repository. Note that if you wish to analyse the files changed, you will need to set the fetch-depth in the checkout action in the workflow to '0'.

-   required: false
-   default: 'false'

### auth-token:
If you are looking to compare the file difference based on the GitHub pull request, you will need to specify the [GitHub secrets token](https://docs.github.com/en/actions/reference/authentication-in-a-workflow)'
    
-   required: false

### error-rules

If you wish to define rules that log as an error, enter each rule name separated with a comma and no spaces. Note that if an error is identified the run will fail. e.g. ClassNamingConventions,GuardLogStatement

-   required: false

### file-diff-type

Choose whether you want the file comparison to be based on a git diff or based on the files changed specified on the GitHub pull request. Note that if you use the GitHub pull request option, this action will only work on a pull request event. Options to set this are either `git` or `github`.
   
-   required: false
-   default: 'git'

### file-path

Path to the sources to analyse. This can be a file name, a directory, or a jar or zip file containing the sources.

-   required: true

### note-rules

If you wish to define rules that log as a note, enter each rule name separated with a comma and no spaces. Note that if a note is identified the run will not fail. e.g. ClassNamingConventions,GuardLogStatement

-   required: false

### pmd-version

The version of PMD you would like to run. You can either specify latest to always get the newest version, or you can specify a version number like 6.37.0.

-   required: false
-   default: 'latest'

### rules-path

The ruleset file you want to use. PMD uses xml configuration files, called rulesets, which specify which rules to execute on your sources. You can also run a single rule by referencing it using its category and name (more details here). For example, you can check for unnecessary modifiers on Java sources with -R category/java/codestyle.xml/UnnecessaryModifier.

-   required: true

## Outputs

### error-found

Identifies whether an error has been found based on the error ruleset. If an error is found 'true' is returned.
