#!/usr/bin/env wolframscript
projectDir = DirectoryName[$InputFileName];
SetDirectory[projectDir];
Get[FileNameJoin[{projectDir, "src", "CardiobandTRModel.wl"}]];
If[!DirectoryQ[FileNameJoin[{projectDir, "exports"}]], CreateDirectory[FileNameJoin[{projectDir, "exports"}]]];
results = CardiobandTRModel`WriteAuditReport[FileNameJoin[{projectDir, "exports", "audit_report.txt"}]];
failed = Count[results[[All, "Pass"]], Except[True]];
Print["Cardioband TR audit checks: ", Length[results] - failed, " passed, ", failed, " failed."];
If[failed > 0, Quit[1], Quit[0]];
