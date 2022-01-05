<h1 align="center">Immuni iOS</h1>

<div align="center">
<img width="256" height="256" src=".github/logo.png">
</div>

<br />

<div align="center">
    <!-- Latest Release -->
    <a href="https://github.com/immuni-app/immuni-app-ios/releases">
      <img alt="GitHub release (latest SemVer)"
      src="https://img.shields.io/github/v/release/immuni-app/immuni-app-ios">
    </a>
    <!-- CoC -->
    <a href="CODE_OF_CONDUCT.md">
      <img src="https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg" />
    </a>
    <a href="https://circleci.com/gh/immuni-app/immuni-app-ios">
      <img alt="Circle CI Status"
      src="https://circleci.com/gh/immuni-app/immuni-app-ios.svg?style=svg">
    </a>
</div>

<div align="center">
  <h3>
    </span>
    <a href="https://github.com/immuni-app/immuni-documentation">
      Documentation
    </a>
    <span> | </span>    
    <a href="CONTRIBUTING.md">
      Contributing
    </a>
  </h3>
</div>

# Table of contents

- [Context](#context)
- [Installation](#installation)
  - [Backend services](#backend-services)
- [UI testing](#ui-testing)
- [Checking the build](#checking-the-build)
- [Contributing](#contributing)
  - [Contributors](#contributors)
- [License](#license)
  - [Authors / Copyright](#authors--copyright)
  - [Third-party component licenses](#third-party-component-licenses)
    - [Tools](#tools)
    - [Libraries](#libraries)
  - [License details](#license-details)

# Context

This repository contains the source code of Immuni's iOS client. More detailed information about Immuni can be found in the following documents:

- [High-Level Description](https://github.com/immuni-app/immuni-documentation)
- [Product Description](https://github.com/immuni-app/immuni-documentation/blob/master/Product.md)
- [Technology Description](https://github.com/immuni-app/immuni-documentation/blob/master/Technology.md)
- [Traffic Analysis Mitigation](https://github.com/immuni-app/immuni-documentation/blob/master/Traffic%20Analysis%20Mitigation.md)

**Please take the time to read and consider these documents in full before digging into the source code or opening an Issue. They contain a lot of details that are fundamental to understanding the source code and this repository's documentation.**

# Installation

The recommended method requires that [Xcode 11.5](https://developer.apple.com/xcode/) and [Brew](https://brew.sh/) are installed on your Mac. If you would prefer to follow a custom method, you have the option not to install Brew. Please refer to the [Makefile](Makefile) to check which dependencies are needed; you may install those manually instead.

```sh
git clone https://github.com/immuni-app/immuni-app-ios.git
cd immuni-app-ios

# This command will install the environment needed to run the project using Brew.
# If you prefer to install them manually, check the Makefile.
# Note: this step should be done just once
make setup
make immuni
```

Please note the following:

- The project may be built and run in the simulator.
- If you wish to install the application on a real device, you will need to join the [Apple Developer Program](https://developer.apple.com/programs/) and sign the App with your certificate.
- Apple requires a [special entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_exposure-notification) to make the [Exposure Notification](https://developer.apple.com/documentation/exposurenotification) system work. To obtain this entitlement, you must be either a government entity or a developer approved by a government entity to develop an application on behalf of a government for COVID-19 response efforts. This is stated in the [APIs addendum](https://developer.apple.com/contact/request/download/Exposure_Notification_Addendum.pdf). You should remove _Exposure Notification_ entitlements from the entitlements file before compiling the application. You may build and use the application, but you will not be able to use the underlying Exposure Notification system.

For more information about how the project is generated and structured, please refer to the [CONTRIBUTING](CONTRIBUTING.md) file.

# UI testing

The repository contains a system that can generate snapshots of the application's UI in different contexts (e.g., in various languages). This is a good way of checking the UI's issues and having an overview of the various UI states. To generate them, set up the project and run `make run_uitests`. The generated screenshots are located in the `UITests/Screenshots` folder.

Please be aware that this process may take some time, depending on your computer's hardware.

# Checking the build

In addition to making the code open-source, we wish to help people verify that builds published on the App Store are coming from a specific commit of this repository. Please refer to the [Immuni Technology Description](https://github.com/immuni-app/immuni-documentation/blob/master/Technology.md#ios-app-technologies) for a complete overview of the goals and status of this effort.

Currently, we have a working open continuous integration for building the client. [Here](.circleci/config.yml) is the full specification. When it comes to reproducible builds, we will instead open an issue explaining what we have done so far and any missing steps.

# Contributing

Contributions are most welcome. Before proceeding, please read the [Code of Conduct](CODE_OF_CONDUCT.md) for guidance on how to approach the community and create a positive environment. Additionally, please read our [CONTRIBUTING](CONTRIBUTING.md) file, which contains guidance on ensuring a smooth contribution process.

The Immuni project is composed of different repositories—one for each component or service. Please use this repository for contributions strictly relevant to the Immuni iOS client. To propose a feature request, please open an issue in the [Documentation repository](https://github.com/immuni-app/immuni-documentation). This lets everyone involved see it, consider it, and participate in the discussion. Opening an issue or pull request in this repository may slow down the overall process.

## Contributors

Here is a list of Immuni's contributors. Thank you to everyone involved for improving Immuni, day by day.

<a href="https://github.com/immuni-app/immuni-app-ios/graphs/contributors">
  <img
  src="https://contributors-img.web.app/image?repo=immuni-app/app-ios"
  />
</a>

# License

## Authors / Copyright

Copyright 2020 (c) Presidenza del Consiglio dei Ministri.

Please check the [AUTHORS](AUTHORS) file for extended reference.

## Third-party component licenses

### Tools

| Name                                                        | License                   |
| ----------------------------------------------------------- | ------------------------- |
| [Brew](https://brew.sh/)                                    | BSD 2-Clause 'Simplified' |
| [Cocoapods](https://cocoapods.org/)                         | MIT                       |
| [CommitLint](https://commitlint.js.org/#/)                  | MIT                       |
| [Danger](https://danger.systems/js/)                        | MIT                       |
| [SwiftFormat](https://github.com/nicklockwood/SwiftFormat/) | MIT                       |
| [SwiftGen](https://github.com/SwiftGen/SwiftGen)            | MIT                       |
| [SwiftLint](https://github.com/realm/SwiftLint)             | MIT                       |
| [XcodeGen](https://github.com/yonaskolb/XcodeGen)           | MIT                       |

### Libraries

| Name                                                       | License    |
| ---------------------------------------------------------- | ---------- |
| [Katana](https://github.com/BendingSpoons/katana-swift)    | MIT        |
| [Tempura](https://github.com/BendingSpoons/tempura-swift/) | MIT        |
| [Alamofire](https://github.com/Alamofire/Alamofire)        | MIT        |
| [BonMot](https://github.com/Rightpoint/BonMot)             | MIT        |
| [Hydra](https://github.com/malcommac/Hydra/)               | MIT        |
| [Lottie](https://github.com/airbnb/lottie-ios)             | Apache 2.0 |
| [PinLayout](https://github.com/layoutBox/PinLayout)        | MIT        |
| [SwiftLog](https://github.com/apple/swift-log/)            | Apache 2.0 |
| [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) | MIT        |

## License details

The licence for this repository is a [GNU Affero General Public Licence version 3](https://www.gnu.org/licenses/agpl-3.0.html) (SPDX: AGPL-3.0). Please see the [LICENSE](LICENSE) file for full reference.
