// swiftlint.ts
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

import { warn, fail, message } from "./danger";
import { promisify } from "util";
import { relative } from "path";

const exec = promisify(require("child_process").exec);

// JSON reporter documented here:
// https://github.com/realm/SwiftLint/blob/master/Source/SwiftLintFramework/Reporters/JSONReporter.swift
type SwiftLintReport = {
  file: string;
  line: number;
  severity: "Warning" | "Error";
  rule_id: string;
  reason: string;
};

export const checkLinting = async (files: string[]) => {
  let reports: SwiftLintReport[];
  let toolVersion: string;

  try {
    toolVersion = (await exec("swiftlint version")).stdout
      .replace(/\s+/g, " ")
      .trim();

    const { stdout } = await exec(
      `swiftlint lint --reporter json ${files.join(" ")}`,
      { encoding: "utf8" }
    );

    reports = JSON.parse(stdout) as SwiftLintReport[];
    swiftlintReportToDanger(reports, toolVersion);
  } catch (error) {
    // If there are errors, the exit code is not 0 and the exec fn throws
    const { killed, code } = error;

    if (killed || code != 2) {
      fail(
        `Swiftlint cannot be executed. This is a CI error killed: ${killed}, code: ${code}`
      );
    } else {
      reports = JSON.parse(error.stdout) as SwiftLintReport[];
      swiftlintReportToDanger(reports, toolVersion);
    }
  }
};

const swiftlintReportToDanger = (
  reports: SwiftLintReport[],
  toolVersion: string
) => {
  if (reports.length == 0) {
    message(`:white_check_mark: Swiftlint (${toolVersion}) passed`);
    return;
  }

  const cwd = process.cwd();

  for (const report of reports) {
    const fn = report.severity === "Warning" ? warn : fail;
    const reportMessage = `swiftlint (${toolVersion}): ${report.reason} (${
      report.rule_id
    })`;
    const file = relative(cwd, report.file);
    fn(reportMessage, file, report.line);
  }
};
