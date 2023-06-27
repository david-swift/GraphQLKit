docs:
	@sourcedocs generate --min-acl private -r --spm-module GraphQLKit

swiftlint:
	@swiftlint --autocorrect
