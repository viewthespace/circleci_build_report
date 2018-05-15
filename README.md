## CircleCI Build Report
This gem is CLI tool for exporting build data for a given CircleCI project and branch in a CSV format. The returned CSV contains only three columns: `build_num`, `start_date`, `status`.

### Install
Install from ruby gems

```
gem install circleci_build_report
```

## Usage

```
circleci_build_report --org=<ORG_NAME> --project=<PROJECT_NAME> --branch=<BRANCH_NAME> --token=<CIRCLE_CI_TOKEN> --out=<FILE_TO_WRITE_TO>
```
