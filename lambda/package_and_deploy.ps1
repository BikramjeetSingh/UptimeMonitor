# Remove old build artifacts
Remove-Item -Recurse -Force package -ErrorAction Ignore
Remove-Item -Force uptime_lambda.zip -ErrorAction Ignore

# Create package directory
New-Item -ItemType Directory -Path package | Out-Null

# Install dependencies INTO package folder
pip install -r lambda/requirements.txt -t package

# Copy Lambda function
Copy-Item lambda/lambda_function.py package/

# Create ZIP file
Compress-Archive -Path package\* -DestinationPath uptime_lambda.zip

Write-Host "Created uptime_lambda.zip"
