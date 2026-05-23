#!/usr/bin/env wolframscript
projectDir = DirectoryName[$InputFileName];
SetDirectory[projectDir];
exportsDir = FileNameJoin[{projectDir, "exports"}];
docsDir = FileNameJoin[{projectDir, "docs"}];
If[!DirectoryQ[exportsDir], CreateDirectory[exportsDir]];
If[!DirectoryQ[docsDir], CreateDirectory[docsDir]];
Get[FileNameJoin[{projectDir, "src", "CardiobandTRModel.wl"}]];
validation = CardiobandTRModel`ExportProjectArtifacts[exportsDir];
simulationSummary = CardiobandTRModel`ExportSimulationArtifacts[exportsDir, 42];
CardiobandTRModel`WriteAuditReport[FileNameJoin[{exportsDir, "audit_report.txt"}]];
required = {
  "audit_report.txt",
  "validation_report.md",
  "validation_results.json",
  "echo_parameters.csv",
  "major_adverse_events.csv",
  "annular_diameter.csv",
  "synthetic_patient_data.csv",
  "synthetic_patient_summary.json",
  "figure_annular_diameter.png",
  "figure_tr_severity_1year.png",
  "figure_kccq.png",
  "figure_major_adverse_events.png",
  "simulation_tr_shift.png",
  "simulation_annular_scatter.png",
  "simulation_kccq_scatter.png",
  "simulation_event_curves.png"
};
missing = Select[required, !FileExistsQ[FileNameJoin[{exportsDir, #}]] || FileByteCount[FileNameJoin[{exportsDir, #}]] == 0 &];
failed = Count[validation[[All, "Pass"]], Except[True]];
If[missing =!= {}, Print["Missing exports: ", missing]; Quit[2]];
If[failed > 0, Print["Validation failures: ", failed]; Quit[1]];
Print["Build complete. Exports written to ", exportsDir];
Quit[0];
