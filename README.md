# Deploy Django application to AWS Lambda

EXPERIMENTAL

Continuous Deliver steps for deploying a Django application as serverless to AWS Lambda.

This project tries to make deploying an existing Django application to AWS Lambda with minimal effort with the support of both [Github Actions](https://github.com/features/actions) or [Bitrise](https://www.bitrise.io/).

Utilizes the [Zappa](https://pypi.org/project/zappa/) framework.

## TODOs, known issues and limitations

All the current [todos](../../search?q=TODO&unscoped_q=TODO) are documented in the code.

Or by command line:
```bash
rg TODO
```

## Prerequisites and how to use

1. Configure the related services you need in your application for example:
  * The database (for example AWS RDS database) (to get the `DATABASE_URL`)
  * CloudFront for serving the static files (for the `DJANGO_STATIC_HOST`). Use for example the [Whitenoise](http://whitenoise.evans.io/en/stable/) library
2. Pick up the Lambda function name and head to AWS console or use the AWS CLI tool to configure your application's environment variables:
```bash
aws lambda update-function-configuration --function-name $LAMBDA_NAME --environment Variables={SECRET_KEY=xxx}
aws lambda update-function-configuration --function-name $LAMBDA_NAME --environment Variables={DATABASE_URL=xxx}
aws lambda update-function-configuration --function-name $LAMBDA_NAME --environment Variables={DJANGO_STATIC_HOST=xxx}
```
3. Create the AWS credentials and associate the AWS IAM policy for [example](aws-iam-policy-for-zappa.json). TODO: A more strict security policy.
4. Deploy your application. The first deployment may fail with the `502` error because of the misconfigurations so check step 2 again.
5. Configure your custom domains in AWS and set the DNS records to point to the API Gateway domain.

## Using with Github Actions

An example of a step configuration you need to your Github workflow definition:

Example file for the development deployment: `.github/workflows/deploy.yml`
```yaml
name: Deploy
on:
  push:
    branches:
      - development
      - master
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to AWS Lambda
        if: github.ref == 'refs/heads/development'
        uses: BuddyHC/bitrise-step-deploy-django-application-to-aws-lambda@master
        with:
          aws_access_key_id: ${{ secrets.DEV_AWS_ACCESS_KEY_ID }}
          aws_secret_access_key: ${{ secrets.DEV_AWS_SECRET_ACCESS_KEY }}
      - name: Deploy to AWS Lambda
        if: github.ref == 'refs/heads/master'
        uses: BuddyHC/bitrise-step-deploy-django-application-to-aws-lambda@master
        with:
          aws_access_key_id: ${{ secrets.PROD_AWS_ACCESS_KEY_ID }}
          aws_secret_access_key: ${{ secrets.PROD_AWS_SECRET_ACCESS_KEY }}
```

Please see [action.yml](action.yml) for additional configuration parameters.

## Bitrise

### How to test this step

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

### How to contribute to this step

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

## Community support

[Gitter](https://gitter.im/cizappa/)