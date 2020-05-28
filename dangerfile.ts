// dangerfile.ts
// Copyright (C) 2020 Presidenza del Consiglio dei Ministri.
// Please refer to the AUTHORS file for more information.
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import { danger, warn, message } from "danger";
import { checkFormat } from "./CI/danger/swiftformat";
import { checkLinting } from "./CI/danger/swiftlint";
import { isAppFile, isTestFile } from "./CI/danger/utils";
import commitLint from "./CI/danger/commitlint";

export default async () => {
  const allFiles = danger.git.created_files.concat(danger.git.modified_files);
  const swiftFiles = allFiles.filter((f) => f.endsWith(".swift"));

  const hasChangedApp = danger.git.modified_files.filter(isAppFile).length > 0;

  const hasChangedTests =
    danger.git.modified_files.filter(isTestFile).length > 0;

  const isDestinationMaster = danger.github.pr.base.ref === "master";
  const isReleaseBranch = danger.github.pr.head.ref.indexOf("release/") !== -1;

  if (isDestinationMaster && !isReleaseBranch) {
    warn(
      "This PR has been opened against master, but the current branch is not a release one. Most likely you need to change destination branch."
    );
  } else if (isDestinationMaster && isReleaseBranch) {
    warn(
      "This PR represents an App Store release and it should be merged only when this version has been released on the store."
    );
  }

  message(
    "Thank you for submitting a pull request! The team will review your submission as soon as possible."
  );

  if (hasChangedApp && !hasChangedTests) {
    warn("Consider adding tests or updating existing tests for your changes.");
  }

  await commitLint({ enabled: true, allowedScopes: [] });

  if (swiftFiles.length > 0) {
    await checkFormat(swiftFiles);
    await checkLinting(swiftFiles);
  }
};
