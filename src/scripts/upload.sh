if ! [[ "$CIRCLE_BRANCH" =~ $INPUT_WHEN_BRANCH_MATCHES ]]
then
	echo "The current branch (${CIRCLE_BRANCH}) does not match the regex specified in the when-branch-matches parameter ($INPUT_WHEN_BRANCH_MATCHES). Skipping BuildPulse upload."
	exit 0
fi

if [ $INPUT_ACCOUNT_ID -eq -1 ]
then
	if [ -z "${BUILDPULSE_ACCOUNT_ID+x}" ]
	then
		echo "No account ID given."
		echo "To resolve this issue, set the buildpulse/upload 'account-id' parameter to your BuildPulse Account ID. Alternatively, you can set the 'BUILDPULSE_ACCOUNT_ID' environment variable to your BuildPulse Account ID."
		exit 1
	else
		ACCOUNT_ID="$BUILDPULSE_ACCOUNT_ID"
	fi
else
	ACCOUNT_ID=$INPUT_ACCOUNT_ID
fi

if [ $INPUT_REPOSITORY_ID -eq -1 ]
then
	if [ -z "${BUILDPULSE_REPOSITORY_ID+x}" ]
	then
		echo "No repository ID given."
		echo "To resolve this issue, set the buildpulse/upload 'repository-id' parameter to the BuildPulse ID for your repository. Alternatively, you can set the 'BUILDPULSE_REPOSITORY_ID' environment variable to the BuildPulse ID for your repository."
		exit 1
	else
		REPOSITORY_ID="$BUILDPULSE_REPOSITORY_ID"
	fi
else
	REPOSITORY_ID=$INPUT_REPOSITORY_ID
fi

REPORT_PATH="${INPUT_PATH}"
if [ ! -d "$REPORT_PATH" ]
then
	echo "The given report path is not a directory: ${REPORT_PATH}"
	echo "To resolve this issue, set the buildpulse/upload 'path' parameter to the directory that contains your test report(s)."
	exit 1
fi

REPOSITORY_PATH="${INPUT_REPOSITORY_PATH}"
if [ ! -d "$REPOSITORY_PATH" ]
then
	echo "The given repository path is not a directory: ${REPOSITORY_PATH}"
	echo "To resolve this issue, set the buildpulse/upload 'repository-path' parameter to the directory that contains the local git clone of your repository."
	exit 1
fi

getcli() {
	urls=(
		https://get.buildpulse.io/test-reporter-linux-amd64
		https://github.com/buildpulse/test-reporter/releases/latest/download/test-reporter-linux-amd64
	)

	for url in ${urls[@]}; do
		(set -x; curl -fsSL --retry 3 --retry-connrefused --connect-timeout 5 $url)
	done;
}

if getcli > ./buildpulse-test-reporter; then
	: # Successfully fetched binary. Great!
else
	cat <<-eos
		❌ Unable to send test results to BuildPulse. See details below.

		Downloading the BuildPulse test-reporter failed with status $?.

		We never want BuildPulse to make your builds unstable. Since we're having
		trouble downloading the BuildPulse test-reporter, we're skipping the
		BuildPulse analysis for this build.

		If you continue seeing this problem, please get in get in touch at
		https://buildpulse.io/contact so we can look into this issue.
	eos

	exit 0
fi

chmod +x ./buildpulse-test-reporter

BUILDPULSE_ACCESS_KEY_ID="${!INPUT_ACCESS_KEY_ID}" \
	BUILDPULSE_SECRET_ACCESS_KEY="${!INPUT_SECRET_ACCESS_KEY}" \
	./buildpulse-test-reporter submit "${REPORT_PATH}" --account-id $ACCOUNT_ID --repository-id $REPOSITORY_ID --repository-dir $REPOSITORY_PATH
