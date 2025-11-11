$bin = "MicrosoftDeploymentToolkit_x64.msi"
Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile C:\installers\$bin
