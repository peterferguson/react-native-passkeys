## Checklist for publishing

### Preparation

1. Update [CHANGELOG.md](CHANGELOG.md) with changes per [Keep a Changelog format](https://keepachangelog.com/).
2. Run `pnpm run build` to ensure the build is successful.
3. Run `pnpm run lint & pnpm run format` to ensure code quality.
4. Run `pnpm run check-exports` to verify type exports are correct.

### Version and Publish

1. Create a new changeset:
   ```bash
   pnpm changeset
   ```
   - Select the type of change (major/minor/patch)
   - Provide a description of the changes

2. Version the package:
   ```bash
   pnpm changeset version
   ```
   This will:
   - Update the version in package.json
   - Update the CHANGELOG.md
   - Remove the used changeset files

3. Publish to npm:
   ```bash
   pnpm publish
   ```
   Note: The `prepublishOnly` script will automatically run the build and check-exports before publishing.

### Post-Publish

1. Push the changes to GitHub:
   ```bash
   git push
   git push --tags
   ```

2. Create a new release on GitHub:
   - Go to the [releases page](https://github.com/peterferguson/react-native-passkeys/releases)
   - Click "Draft a new release"
   - Select the new tag
   - Copy the relevant changelog entries
   - Publish the release

### Verify Installation

1. Test the new version in a fresh project:
   ```bash
   pnpm add react-native-passkeys@latest
   ```

2. Verify the example app works with the new version:
   ```bash
   cd example
   pnpm install
   pnpm run ios  # or android
   ```