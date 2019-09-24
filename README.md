# Deploy Django application to AWS Lambda

EXPERIMENTAL

Bitrise steps for deploying a Django application as serverless to AWS Lambda.

Utilizes Zappa (https://pypi.org/project/zappa/).

## TODO

All the current todos are documented in the code:

```bash
rg TODO
```

## How to test this step

Can be run directly with the [bitrise CLI](https://github.com/bitrise-io/bitrise),
just `git clone` this repository, `cd` into it's folder in your Terminal/Command Line
and call `bitrise run test`.

Step by step:

1. Open up your Terminal / Command Line
2. `git clone` the repository
3. `cd` into the directory of the step (the one you just `git clone`d)
4. Create AWS credentials for running the tests. You can associate the attached policy [aws-iam-policy-for-zappa.json](aws-iam-policy-for-zappa.json) to the credentials on AWS.
5. Create a `.bitrise.secrets.yml` file in the same directory of `bitrise.yml`
   (the `.bitrise.secrets.yml` is a git ignored file, you can store your secrets in it)
   The `.bitrise.secrets.yml` should contain the following in order to run the from local computer and deploy the test project to AWS:
  ```yaml
  envs:
  - AWS_ACCESS_KEY_ID: AKIAXXXXXXXXXXXXXXXX
  - AWS_SECRET_ACCESS_KEY: XXXXXXXXXXXXXXXXXXXXXXXX
  ```
6. Once you have all the required secret parameters in your `.bitrise.secrets.yml` you can just run this step with the [bitrise CLI](https://github.com/bitrise-io/bitrise): `bitrise run test`

## How to contribute to this step

1. Fork this repository
2. `git clone` it
3. Create a branch you'll work on
4. To use/test the step just follow the **How to use this Step** section
5. Do the changes you want to
6. Run/test the step before sending your contribution
  * You can also test the step in your `bitrise` project, either on your Mac or on [bitrise.io](https://www.bitrise.io)
  * You just have to replace the step ID in your project's `bitrise.yml` with either a relative path, or with a git URL format
  * (relative) path format: instead of `- original-step-id:` use `- path::./relative/path/of/script/on/your/Mac:`
  * direct git URL format: instead of `- original-step-id:` use `- git::https://github.com/user/step.git@branch:`
  * You can find more example of alternative step referencing at: https://github.com/bitrise-io/bitrise/blob/master/_examples/tutorials/steps-and-workflows/bitrise.yml
7. Once you're done just commit your changes & create a Pull Request
