# Table of contents

- [Contributing instructions](#contributing-instructions)
- [Architecture](#architecture)
  - [Environment](#environment)
  - [Repository structure](#repository-structure)
  - [Modules](#modules)
  - [Code style](#code-style)
  - [Testing](#testing)
- [Gitflow](#gitflow)
  - [Feature and fixes](#feature-and-fixes)
  - [Releases](#releases)
- [Commits](#commits)
- [How to contribute](#how-to-contribute)
  - [Issues](#issues)
    - [Creating a new issue](#creating-a-new-issue)
    - [Good first issues](#good-first-issues)
  - [Pull requests](#pull-requests)
    - [Pull request checks](#pull-request-checks)
- [Labels](#labels)

# Contributing instructions

Thank you for considering making a contribution to this repository. In this file, you will find guidelines for contributing efficiently. If you are unsure whether this is the appropriate repository for a particular issue, please review the repository structure of this organisation.

Please do not file an issue to ask a question. You will get faster results by using the resources below.

Before proceeding, please review our [Code of Conduct](CODE_OF_CONDUCT.md).

# Architecture

This section describes the project's architecture. Please read it thoroughly before contributing to the project.

## Environment

The application has been developed using [Xcode 11.5](https://developer.apple.com/xcode/) and [Swift 5.2](https://swift.org/).

Some additional tools are used to set up the project.

- **[XcodeGen](https://github.com/yonaskolb/XcodeGen)**. We use XcodeGen to generate the xcodeproj file, starting from a YML file. We made this choice to lower the likelihood of introducing bugs into the project configuration—especially a wrong conflict resolution during a pull request.
- **[SwiftGen](https://github.com/SwiftGen/SwiftGen)**. We use SwiftGen to generate typesafe code to access localisation strings and assets.
- **[Cocoapods](https://cocoapods.org/)**. We use Cocoapods as a dependencies manager.

These tools are installed during the setup phase (that is, when running `make setup`).

## Repository structure

The application root folder contains the following folders:

- **App**. This contains the core logic of the application and UI.
- **AppTests**. This contains the tests for the application's logic.
- **UITests**. This contains the UI tests.

The App folder is grouped by concerns. In particular:

- **Application**. This contains files needed to bootstrap the application.
- **Dependencies**. This contains the managers used by Katana Side Effects to implement the application's logic. Managers expose reusable functionalities and tend to have little state. Although not always possible, a manager should ideally be a collection of pure functions.
- **Logic**. This contains the Katana Side Effects and Katana State Updaters. Side Effects and State Updaters are namespaced by feature to improve readability and discoverability.
- **Resources**. This contains the resources (e.g., fonts, assets, localization files) used by the application.
- **State**. This contains the Katana State.
- **Style**. This contains reusable styles and resources used to implement the application's UI.
- **UI**. This contains the implementation of the application's UI, grouped by feature. The UI is implemented following Tempura principles.

## Modules

The application's core logic leverages a set of modules. Modules are parts of the application included as separate frameworks to improve the division of concerns and readability of the project. These include the following:

- **Debug Menu**. This provides helpers that simplify the development and QA processes. This module is not shipped in production builds.
- **Extensions**. This contains a set of extensions and helpers.
- **Immuni Exposure Notification**. This is a wrapper around Apple's Exposure Notification.
- **Models**. This contains the models of the application.
- **Networking**. This is a small layer on top of Alamofire. It also contains the logic to create requests for Immuni's backend and to deserialise responses and errors.
- **Persistence**. This provides a system to interact with Apple's file system, UserDefaults, and Keychain Services. Moreover, it takes care of encrypting everything it has stored in UserDefaults.
- **Push Notification**. This is a small layer on top of Apple's UserNotifications framework.
- **Store Persistence**. This implements a system that persists and encrypts the Katana State.

## Code style

The source code should be linted using [SwiftLint](https://github.com/realm/SwiftLint) and formatted using [SwiftFormat](https://github.com/nicklockwood/SwiftFormat/).

We have decided not to include the linter or the formatter as build phases to prevent increasing the application build time. However, there are some helpers in place.

If you have set up the project using Make setup, the script has installed a _pre-commit hook_ on your git folder. You can check it in the [Makefile](Makefile). This script automatically formats the source code and solves most of the linting issues. If the linter finds issues that it cannot fix automatically, the commit fails. If you prefer not to have this mechanism in place, either do not set up the project using make setup or delete the .`git/hooks/pre-commit` file. However, we recommend running these commands before each commit.

```sh
swiftformat .
swiftlint autocorrect
```

When a new pull request is opened, the CI checks for formatting or linting issues. Please solve them before we can proceed with the review.

## Testing

The application has both logic tests (_Immuni Tests_ target) and UI tests (_Immuni UITests_ target). The former is developed using [XCTest](https://developer.apple.com/documentation/xctest), while the latter leverages [an extension of the Tempura library](https://github.com/BendingSpoons/tempura-swift/#ui-testing).

When contributing with a pull request, please make sure that the existing test passes and that relevant tests are added for the changes you are introducing.

# Gitflow

This repository adopts a branch management system inspired by [Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow). However, given that, in Android and iOS, continuous delivery is not possible, branches are used in a slightly different manner.

The main branches are as follows:

- **Master**. The _master branch_ contains the codebase that has reached the production environment (i.e., the App Store or Google Play). Commits are manually merged in this branch by project maintainers when a new build reaches the production environment.
- **Development**. The _development branch_ is where development takes place. This branch serves as an integration branch for features and fixes—it could be considered the unstable beta branch.

## Feature and fixes

When contributors wish to implement a new feature or a fix, they should branch from the development branch and open a pull request. Branches should have a meaningful name that adheres to the following convention:

```
<type>/name_of_feature_or_fix.
```

The _type_ prefix should be one of the following:

- **feature**. Used in the case that the branch implements a new feature.
- **fix**. Used in the case that the branch implements a fix.

Valid branch names are:

- _feature/onboarding_
- _fix/paddings_

Invalid branch names are:

- _feat/onboarding_
- _fix_paddings_

## Releases

When the code is ready for a new release, a new release branch is cut from development. From the [Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) website:

_Once development has acquired enough features for a release (or a predetermined release date is approaching), you fork a release branch off from development. Creating this branch starts the next release cycle, so no new features can be added after this point—only bug fixes, documentation generation, and other release-oriented tasks should go in this branch._

During this stage, the focus is on preparing the release by fixing issues. It is not possible to add new features to the codebase.

Once Apple and/or Google approve the build, the release branch is merged in both development and master.

# Commits

Please follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/) naming convention for consistency and to avoid problems with our continuous integration systems. The automatic systems also perform checks and mark as not ready for review any pull request that it determines has not followed the convention.

# How to contribute

When you encounter a bug or an issue with the system represented in this repository, you may choose to let the developers know the nature of the issue.

The Immuni project is composed of different repositories—one for each component or service. If you wish to raise something strictly relevant to this repository (i.e., an iOS bug), please read on. However, to raise other issues or to highlight other bugs, please open an issue in the [Documentation repository](https://github.com/immuni-app/immuni-documentation). This lets everyone involved see it, consider it, and participate in the discussion, without slowing down the overall process.

## Issues

Before filing a new issue, please browse the relevant section and use the search functionality to check if it has already been filed by someone else.

- If this issue has previously been filed, please do not create a new one. Instead, add more information to the existing issue, or simply add the 👍 symbol to the first message. This helps the project maintainers to identify issues and prioritise accordingly.
- If the issue has not already been filed, please create a new one.

### Creating a new issue

When creating a new issue, there are three categories:

- Bug report
- iOS client feature request
- General issue

Please ensure that you select the appropriate category for the issue. Each one has a unique template designed to elicit the information required to reproduce and fix the issue. If the issue does not fall under _Bug report_ or _iOS client feature request_, please select _General issue_. With a general issue, it is especially important to provide a significant amount of detail, to help the project maintainers and any other collaborators understand the issue clearly.

When an issue is opened, a triage label is automatically assigned. The project maintainers are automatically notified of the issue's creation—they endeavour to address all issues as quickly as possible. When the issue has been triaged, a corresponding label will be assigned. Here is a list of [all the possible labels](#labels).

### Good first issues

If you are interested in contributing to Immuni but are unsure where to start, please search for issues with the Good first issue label. These issues are relatively easy tasks that can help you get familiar with the code.

## Pull requests

After opening an issue, you may want to help the developers further. If the issue has been triaged and if the project maintainers give the green light, you may propose a solution. Doing so is always appreciated. For this, please use the Pull Request tool.

Before proceeding, please ensure that your proposal relates to an issue that has already been reviewed.

The first step in opening a pull request is to fork the project. Please log in to your account, then select Fork in the repository's landing page. This allows you to work on a dedicated fork and push your changes there. Then, if you wish to apply these changes back in the main Immuni repository, create a pull request targeting this repository. For more detailed information, [please read this guide](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork).

When creating a pull request, please choose a name that adheres to the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/) naming convention. It is important to review and follow this convention before creating a pull request. This ensures that the commit history remains clean and makes it easy to identify what each commit does.

After choosing the appropriate name, please use the following template for the body of the pull request:

```
<!--- IMPORTANT: Please review [how to contribute](../CONTRIBUTING.md) before proceeding further. -->
<!--- IMPORTANT: If this is a Work in Progress PR, please mark it as such in GitHub. -->

## Description

<!--- Describe in detail the proposed mods -->

This PR tackles:

- ...
- ...
- ...

In particular, the ...

## Checklist

<!--- Please insert an ‘x’ after you complete each step -->

- [ ] I have followed the indications in the [CONTRIBUTING](../CONTRIBUTING.md).
- [ ] The documentation related to the proposed change has been updated accordingly (plus comments in code).
- [ ] I have written new tests for my core changes, as applicable.
- [ ] I have successfully run tests with my changes locally.
- [ ] It is ready for review! :rocket:

## Fixes

<!-- Please insert the issue numbers after the # symbol -->

- Fixes #ISSUE_NUMBER
```

There is a checklist indicating the different steps to follow. After completing each step, please mark it as such by inserting an X between the [ ]. When all the steps have been completed, the review process begins.

### Pull request checks

When a new pull request is opened, the CI performs some checks. These are as follows:

- Verification that the commits respect the repository's convention
- Verification that the source code is properly formatted
- Verification that the source code is properly linted

Please ensure that the relevant tests have been run and the CI processes triggered by pull request commits pass without any failures. This is mandatory—we do not review pull requests that fall foul of this rule.

# Labels

Labels are used to tag issues and make them more easily discoverable. Please refer to the [Github website](https://guides.github.com/features/issues/) for more information.

| Name             | Description                                                                |
| ---------------- | -------------------------------------------------------------------------- |
| bug              | Indicates an unexpected problem or unintended behaviour                    |
| documentation    | Indicates that improvements or additions to the documentation are needed   |
| duplicate        | Indicates similar issues or pull requests                                  |
| enhancement      | Indicates new feature requests                                             |
| good first issue | Indicates a good issue for first-time contributors                         |
| help wanted      | Indicates that a project maintainer wants help on an issue or pull request |
| invalid          | Indicates that an issue or pull request is no longer relevant              |
| question         | Indicates that an issue or pull request needs more information             |
| wontfix          | Indicates that work won't continue on an issue or pull request             |
| triage           | Indicates that the issue still needs to be triaged                         |
| QA               | Label coming directly from the QA department                               |
