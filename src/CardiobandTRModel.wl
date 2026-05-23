BeginPackage["CardiobandTRModel`"]

PaperMetadata::usage = "PaperMetadata[] returns citation and study metadata for the Cardioband TR EFS 1-year outcomes paper.";
AnnularDiameterData::usage = "AnnularDiameterData[] returns unpaired annular diameter means from the central illustration.";
PairedAnnularResult::usage = "PairedAnnularResult[] returns the paired 1-year annular reduction claim from the central illustration.";
TRGradeOutcomeData::usage = "TRGradeOutcomeData[] returns aggregate 1-year tricuspid regurgitation severity outcomes.";
EchoParameterData::usage = "EchoParameterData[] returns Table 2 aggregate echocardiographic parameters.";
FunctionalOutcomeData::usage = "FunctionalOutcomeData[] returns NYHA, KCCQ, and 6-minute walk aggregate outcomes.";
MajorAdverseEventData::usage = "MajorAdverseEventData[] returns Table 4 major adverse event counts and percentages.";
RecomputeClaims::usage = "RecomputeClaims[] recomputes paper-level percentages, reductions, and t-test checks from reported aggregates.";
RunValidationSuite::usage = "RunValidationSuite[] returns paper-specific validation checks as a list of associations.";
WriteAuditReport::usage = "WriteAuditReport[path] writes a human-readable audit report and returns the validation results.";
ExportProjectArtifacts::usage = "ExportProjectArtifacts[dir] exports figures, tables, and validation data into dir.";
SimulatePatientDataset::usage = "SimulatePatientDataset[seed] returns clearly labeled synthetic patient-level data constrained to the paper's published aggregate outcomes. These are not real trial records.";
SummarizeSimulatedDataset::usage = "SummarizeSimulatedDataset[data] summarizes synthetic patient-level outcomes against the paper's aggregate targets.";
ExportSimulationArtifacts::usage = "ExportSimulationArtifacts[dir, seed] exports synthetic patient-level CSV data and demo figures into dir.";

Begin["`Private`"]

round1[x_] := N[Round[10 x]/10];
round2[x_] := N[Round[100 x]/100];
percent[n_, d_] := round1[100.0 n/d];
within[actual_, expected_, tol_: 0.15] := Abs[N[actual - expected]] <= tol;
twoSidedTPValue[mean_, sd_, n_] := Module[{t},
  t = Abs[N[mean/(sd/Sqrt[n])]];
  N[2 (1 - CDF[StudentTDistribution[n - 1], t])]
];
rescaleToMeanSD[values_, targetMean_, targetSD_] := Module[{sd = StandardDeviation[values]},
  If[sd == 0, ConstantArray[N[targetMean], Length[values]], N[targetMean + targetSD (values - Mean[values])/sd]]
];
gradeName[grade_] := Switch[grade, 1, "None/Trace", 2, "Mild", 3, "Moderate", 4, "Severe", 5, "Massive", 6, "Torrential", _, "Unknown"];
eventCurve[eventDays_, n_] := Module[{days = Sort[eventDays], surv = 1.0, points},
  points = {{0, 1.0}};
  Do[
    surv = surv - 1.0/n;
    points = Join[points, {{d, points[[-1, 2]]}, {d, surv}}],
    {d, days}
  ];
  Join[points, {{365, surv}}]
];

PaperMetadata[] := <|
  "Title" -> "1-Year Outcomes of Cardioband Tricuspid Valve Reconstruction System Early Feasibility Study",
  "Authors" -> "Gray WA et al.",
  "Journal" -> "JACC: Cardiovascular Interventions",
  "Year" -> 2022,
  "VolumeIssuePages" -> "15(19):1921-1932",
  "DOI" -> "10.1016/j.jcin.2022.07.006",
  "ClinicalTrialsID" -> "NCT03382457",
  "Design" -> "Prospective, single-arm, multicenter early feasibility study",
  "IntentToTreatN" -> 37,
  "OneYearAvailableN" -> 29,
  "PrimaryReproductionScope" -> "Aggregate trial outcome reconstruction from published tables and figures; no patient-level data were available."
|>;

AnnularDiameterData[] := {
  <|"Timepoint" -> "Baseline", "N" -> 37, "MeanCm" -> 4.56|>,
  <|"Timepoint" -> "Discharge", "N" -> 35, "MeanCm" -> 3.94|>,
  <|"Timepoint" -> "30 Days", "N" -> 33, "MeanCm" -> 3.88|>,
  <|"Timepoint" -> "6 Months", "N" -> 26, "MeanCm" -> 3.63|>,
  <|"Timepoint" -> "1 Year", "N" -> 24, "MeanCm" -> 3.51|>
};

PairedAnnularResult[] := <|
  "N" -> 24,
  "BaselineMm" -> 44.6,
  "OneYearMm" -> 35.1,
  "ReportedPercentReduction" -> 21.3,
  "ReportedP" -> "P < 0.0001"
|>;

TRGradeOutcomeData[] := <|
  "N" -> 26,
  "PatientsAtMostModerateAt1Year" -> 19,
  "ReportedPercentAtMostModerate" -> 73.0,
  "PatientsWithAtLeastTwoGradeReduction" -> 19,
  "ReportedPercentAtLeastTwoGradeReduction" -> 73.1,
  "PatientsWithAtLeastOneGradeReduction" -> 26,
  "ReportedAllImprovedAtLeastOneGrade" -> 100.0,
  "OneYearSeverityPercent" -> <|
    "NoneTrace" -> 3.8,
    "Mild" -> 19.2,
    "Moderate" -> 50.0,
    "Severe" -> 23.1,
    "Massive" -> 3.8,
    "Torrential" -> 0.0
  |>,
  "ReportedP" -> "P < 0.0001 by Wilcoxon signed rank test"
|>;

EchoParameterData[] := {
  <|"Parameter" -> "Mean vena contracta", "Unit" -> "cm", "BaselineMean" -> 1.5, "BaselineSD" -> 0.4, "BaselineN" -> 36, "Day30Mean" -> 0.9, "Day30SD" -> 0.4, "Day30N" -> 32, "Year1Mean" -> 0.7, "Year1SD" -> 0.3, "Year1N" -> 26, "DeltaMean" -> -0.8, "DeltaSD" -> 0.5, "DeltaN" -> 25, "ReportedP" -> "P < 0.0001"|>,
  <|"Parameter" -> "2D PISA EROA", "Unit" -> "cm^2", "BaselineMean" -> 0.8, "BaselineSD" -> 0.4, "BaselineN" -> 33, "Day30Mean" -> 0.5, "Day30SD" -> 0.4, "Day30N" -> 27, "Year1Mean" -> 0.3, "Year1SD" -> 0.2, "Year1N" -> 25, "DeltaMean" -> -0.5, "DeltaSD" -> 0.3, "DeltaN" -> 22, "ReportedP" -> "P < 0.0001"|>,
  <|"Parameter" -> "TV tenting height", "Unit" -> "cm", "BaselineMean" -> 0.8, "BaselineSD" -> 0.3, "BaselineN" -> 37, "Day30Mean" -> 0.8, "Day30SD" -> 0.4, "Day30N" -> 29, "Year1Mean" -> 0.7, "Year1SD" -> 0.3, "Year1N" -> 19, "DeltaMean" -> -0.2, "DeltaSD" -> 0.3, "DeltaN" -> 19, "ReportedP" -> "P = 0.0299"|>,
  <|"Parameter" -> "RA volume", "Unit" -> "mL", "BaselineMean" -> 141.1, "BaselineSD" -> 46.3, "BaselineN" -> 37, "Day30Mean" -> 109.5, "Day30SD" -> 41.5, "Day30N" -> 34, "Year1Mean" -> 102.2, "Year1SD" -> 48.7, "Year1N" -> 25, "DeltaMean" -> -30.6, "DeltaSD" -> 31.7, "DeltaN" -> 25, "ReportedP" -> "P < 0.0001"|>,
  <|"Parameter" -> "RV end-diastolic diameter", "Unit" -> "cm", "BaselineMean" -> 4.2, "BaselineSD" -> 0.7, "BaselineN" -> 37, "Day30Mean" -> 3.7, "Day30SD" -> 0.6, "Day30N" -> 32, "Year1Mean" -> 3.6, "Year1SD" -> 0.8, "Year1N" -> 26, "DeltaMean" -> -0.6, "DeltaSD" -> 0.6, "DeltaN" -> 26, "ReportedP" -> "P < 0.0001"|>,
  <|"Parameter" -> "Inferior vena contracta diameter", "Unit" -> "cm", "BaselineMean" -> 2.8, "BaselineSD" -> 0.8, "BaselineN" -> 36, "Day30Mean" -> 2.5, "Day30SD" -> 0.9, "Day30N" -> 34, "Year1Mean" -> 2.2, "Year1SD" -> 0.8, "Year1N" -> 26, "DeltaMean" -> -0.4, "DeltaSD" -> 0.6, "DeltaN" -> 25, "ReportedP" -> "P = 0.0006"|>,
  <|"Parameter" -> "LVEF by Simpson method", "Unit" -> "%", "BaselineMean" -> 57.6, "BaselineSD" -> 5.7, "BaselineN" -> 33, "Day30Mean" -> 58.2, "Day30SD" -> 7.0, "Day30N" -> 34, "Year1Mean" -> 59.3, "Year1SD" -> 5.9, "Year1N" -> 26, "DeltaMean" -> 1.6, "DeltaSD" -> 4.6, "DeltaN" -> 24, "ReportedP" -> "P = 0.1010"|>,
  <|"Parameter" -> "RV TAPSE", "Unit" -> "cm", "BaselineMean" -> 1.7, "BaselineSD" -> 0.3, "BaselineN" -> 37, "Day30Mean" -> 1.6, "Day30SD" -> 0.4, "Day30N" -> 33, "Year1Mean" -> 1.6, "Year1SD" -> 0.5, "Year1N" -> 26, "DeltaMean" -> -0.1, "DeltaSD" -> 0.5, "DeltaN" -> 26, "ReportedP" -> "P = 0.2254"|>
};

FunctionalOutcomeData[] := <|
  "NYHA" -> <|"N" -> 26, "BaselineClassIOrIIPercent" -> 46.2, "OneYearClassIOrIIPercent" -> 92.3, "ReportedP" -> "P < 0.0001"|>,
  "KCCQ" -> <|"N" -> 26, "BaselineMean" -> 57.3, "BaselineSD" -> 24.3, "OneYearMean" -> 76.4, "OneYearSD" -> 23.7, "ChangeMean" -> 19.0, "ChangeSD" -> 19.2, "ReportedP" -> "P < 0.0001"|>,
  "SixMinuteWalk" -> <|"N" -> 20, "ChangeMeanMeters" -> 7.2, "ChangeSDMeters" -> 132.7, "ReportedP" -> 0.8112, "Bins" -> {<|"Change" -> ">=30 m", "Count" -> 6|>, <|"Change" -> "10-29 m", "Count" -> 6|>, <|"Change" -> "0-9 m", "Count" -> 1|>, <|"Change" -> "<0 m", "Count" -> 7|>}|>
|>;

MajorAdverseEventData[] := {
  <|"Event" -> "Cardiovascular mortality", "Day30Count" -> 0, "Year1Count" -> 3, "Year1Percent" -> 8.1|>,
  <|"Event" -> "Myocardial infarction", "Day30Count" -> 0, "Year1Count" -> 0, "Year1Percent" -> 0.0|>,
  <|"Event" -> "Stroke", "Day30Count" -> 0, "Year1Count" -> 2, "Year1Percent" -> 5.4|>,
  <|"Event" -> "Right coronary artery perforation", "Day30Count" -> 0, "Year1Count" -> 0, "Year1Percent" -> 0.0|>,
  <|"Event" -> "Arrhythmia/conduction disorder requiring permanent pacing", "Day30Count" -> 0, "Year1Count" -> 0, "Year1Percent" -> 0.0|>,
  <|"Event" -> "New renal replacement therapy", "Day30Count" -> 0, "Year1Count" -> 0, "Year1Percent" -> 0.0|>,
  <|"Event" -> "Reintervention on study device", "Day30Count" -> 0, "Year1Count" -> 2, "Year1Percent" -> 5.4|>,
  <|"Event" -> "Severe bleeding", "Day30Count" -> 8, "Year1Count" -> 13, "Year1Percent" -> 35.1|>,
  <|"Event" -> "Tamponade", "Day30Count" -> 1, "Year1Count" -> 1, "Year1Percent" -> 2.7|>,
  <|"Event" -> "Major access site/vascular complication", "Day30Count" -> 3, "Year1Count" -> 3, "Year1Percent" -> 8.1|>,
  <|"Event" -> "All-cause mortality", "Day30Count" -> 0, "Year1Count" -> 5, "Year1Percent" -> 13.5|>,
  <|"Event" -> "Heart failure hospitalization", "Day30Count" -> 1, "Year1Count" -> 4, "Year1Percent" -> 10.8|>
};

SimulatePatientDataset[seed_: 42] := Module[
  {n = 37, followN = 26, ids, followIds, year1TR, baselineTR, ages, sexes, annBase, annYear1,
   kccqBase, kccqChange, kccqOneYear, walkChange, cvDeathIds, deathIds, hfIds, bleedIds, strokeIds, rows, baselineGrade},
  SeedRandom[seed];
  ids = Range[n];
  followIds = Range[followN];
  year1TR = RandomSample[Flatten[{ConstantArray[1, 1], ConstantArray[2, 5], ConstantArray[3, 13], ConstantArray[4, 6], ConstantArray[5, 1]}]];
  baselineTR = Map[If[# <= 3, RandomChoice[{5, 6}], Min[6, # + 1]]&, year1TR];
  ages = Round[Clip[RandomVariate[NormalDistribution[77.5, 7.5], n], {55, 94}], 0.1];
  sexes = RandomSample[Join[ConstantArray["Female", 28], ConstantArray["Male", 9]]];
  annBase = rescaleToMeanSD[RandomVariate[NormalDistribution[44.6, 4.0], followN], 44.6, 4.0];
  annYear1 = annBase - rescaleToMeanSD[RandomVariate[NormalDistribution[9.5, 4.5], followN], 9.5, 4.5];
  kccqBase = Clip[rescaleToMeanSD[RandomVariate[NormalDistribution[57.3, 24.3], followN], 57.3, 24.3], {0, 100}];
  kccqChange = rescaleToMeanSD[RandomVariate[NormalDistribution[19.0, 19.2], followN], 19.0, 19.2];
  kccqOneYear = Clip[kccqBase + kccqChange, {0, 100}];
  kccqOneYear = Clip[kccqOneYear + (76.4 - Mean[kccqOneYear]), {0, 100}];
  walkChange = rescaleToMeanSD[RandomVariate[NormalDistribution[7.2, 132.7], 20], 7.2, 132.7];
  deathIds = RandomSample[ids, 5];
  cvDeathIds = RandomSample[deathIds, 3];
  hfIds = RandomSample[Complement[ids, deathIds], 4];
  bleedIds = RandomSample[ids, 13];
  strokeIds = RandomSample[ids, 2];
  rows = Table[
    baselineGrade = If[i <= followN, baselineTR[[i]], RandomChoice[{4, 5, 6}]];
    <|
      "Synthetic" -> True,
      "NotRealPatientData" -> True,
      "Seed" -> seed,
      "PatientID" -> "S" <> IntegerString[i, 10, 3],
      "Age" -> ages[[i]],
      "Sex" -> sexes[[i]],
      "HasOneYearEcho" -> MemberQ[followIds, i],
      "TRGradeBaselineNumeric" -> baselineGrade,
      "TRGradeBaseline" -> gradeName[baselineGrade],
      "TRGradeOneYearNumeric" -> If[i <= followN, year1TR[[i]], Missing["NoFollowUp"]],
      "TRGradeOneYear" -> If[i <= followN, gradeName[year1TR[[i]]], Missing["NoFollowUp"]],
      "AnnularDiameterBaselineMm" -> If[i <= followN, Round[annBase[[i]], 0.1], Missing["NoFollowUp"]],
      "AnnularDiameterOneYearMm" -> If[i <= followN, Round[annYear1[[i]], 0.1], Missing["NoFollowUp"]],
      "KCCQBaseline" -> If[i <= followN, Round[kccqBase[[i]], 0.1], Missing["NoFollowUp"]],
      "KCCQOneYear" -> If[i <= followN, Round[kccqOneYear[[i]], 0.1], Missing["NoFollowUp"]],
      "SixMinuteWalkChangeM" -> If[i <= Length[walkChange], Round[walkChange[[i]], 0.1], Missing["NotMeasured"]],
      "AllCauseDeath1Y" -> MemberQ[deathIds, i],
      "CardiovascularDeath1Y" -> MemberQ[cvDeathIds, i],
      "HeartFailureHospitalization1Y" -> MemberQ[hfIds, i],
      "SevereBleeding1Y" -> MemberQ[bleedIds, i],
      "Stroke1Y" -> MemberQ[strokeIds, i]
    |>,
    {i, ids}
  ];
  rows
];

SummarizeSimulatedDataset[data_] := Module[{follow = Select[data, TrueQ[#HasOneYearEcho]&], walk = Select[data, NumberQ[#SixMinuteWalkChangeM]&]},
  <|
    "Rows" -> Length[data],
    "SyntheticWarning" -> "These rows are simulated for demonstration only and are not real Cardioband patient-level trial data.",
    "FollowUpRows" -> Length[follow],
    "TRAtMostModerate1YPercent" -> percent[Count[follow[[All, "TRGradeOneYearNumeric"]], x_ /; x <= 3], Length[follow]],
    "TRAtLeastTwoGradeReductionPercent" -> percent[Count[follow, row_ /; row["TRGradeBaselineNumeric"] - row["TRGradeOneYearNumeric"] >= 2], Length[follow]],
    "MeanAnnularReductionPercent" -> round1[100 (Mean[follow[[All, "AnnularDiameterBaselineMm"]]] - Mean[follow[[All, "AnnularDiameterOneYearMm"]]])/Mean[follow[[All, "AnnularDiameterBaselineMm"]]]],
    "KCCQMeanChange" -> round1[Mean[follow[[All, "KCCQOneYear"]] - follow[[All, "KCCQBaseline"]]]],
    "SixMinuteWalkMeanChangeM" -> round1[Mean[walk[[All, "SixMinuteWalkChangeM"]]]],
    "AllCauseDeathPercent" -> percent[Count[data[[All, "AllCauseDeath1Y"]], True], Length[data]],
    "CardiovascularDeathPercent" -> percent[Count[data[[All, "CardiovascularDeath1Y"]], True], Length[data]],
    "HeartFailureHospitalizationPercent" -> percent[Count[data[[All, "HeartFailureHospitalization1Y"]], True], Length[data]],
    "SevereBleedingPercent" -> percent[Count[data[[All, "SevereBleeding1Y"]], True], Length[data]]
  |>
];

RecomputeClaims[] := Module[{paired = PairedAnnularResult[], tr = TRGradeOutcomeData[], fun = FunctionalOutcomeData[], meta = PaperMetadata[]},
  <|
    "FemalePercent" -> percent[28, meta["IntentToTreatN"]],
    "OneYearFollowUpPercent" -> percent[meta["OneYearAvailableN"], meta["IntentToTreatN"]],
    "PairedAnnularPercentReduction" -> round1[100 (paired["BaselineMm"] - paired["OneYearMm"])/paired["BaselineMm"]],
    "TRAtMostModeratePercent" -> percent[tr["PatientsAtMostModerateAt1Year"], tr["N"]],
    "TRAtLeastTwoGradeReductionPercent" -> percent[tr["PatientsWithAtLeastTwoGradeReduction"], tr["N"]],
    "TRAtLeastOneGradeReductionPercent" -> percent[tr["PatientsWithAtLeastOneGradeReduction"], tr["N"]],
    "KCCQChangeFromMeans" -> round1[fun["KCCQ", "OneYearMean"] - fun["KCCQ", "BaselineMean"]],
    "KCCQPairedTP" -> twoSidedTPValue[fun["KCCQ", "ChangeMean"], fun["KCCQ", "ChangeSD"], fun["KCCQ", "N"]],
    "SixMinuteWalkTP" -> twoSidedTPValue[fun["SixMinuteWalk", "ChangeMeanMeters"], fun["SixMinuteWalk", "ChangeSDMeters"], fun["SixMinuteWalk", "N"]],
    "SurvivalFromAllCauseMortality" -> round1[100 - percent[5, meta["IntentToTreatN"]]],
    "FreedomFromHFHospitalizationCountBased" -> round1[100 - percent[4, meta["IntentToTreatN"]]],
    "ReportedKaplanMeierSurvival" -> 85.9,
    "ReportedKaplanMeierFreedomFromHFHospitalization" -> 88.7
  |>
];

validation[name_, actual_, expected_, tol_: 0.15] := <|
  "Check" -> name,
  "Actual" -> actual,
  "Expected" -> expected,
  "Tolerance" -> tol,
  "Pass" -> TrueQ[within[actual, expected, tol]]
|>;

RunValidationSuite[] := Module[{claims = RecomputeClaims[], fun = FunctionalOutcomeData[], mae = MajorAdverseEventData[], echo = EchoParameterData[]},
  Join[
    {
      validation["female baseline percentage: 28/37", claims["FemalePercent"], 75.7],
      validation["1-year follow-up availability: 29/37", claims["OneYearFollowUpPercent"], 78.4],
      validation["paired annular reduction percentage", claims["PairedAnnularPercentReduction"], PairedAnnularResult[]["ReportedPercentReduction"]],
      validation["TR <= moderate at 1 year: 19/26", claims["TRAtMostModeratePercent"], 73.1, 0.25],
      validation["TR >=2 grade reduction at 1 year: 19/26", claims["TRAtLeastTwoGradeReductionPercent"], 73.1],
      validation["all paired 1-year patients improved >=1 TR grade", claims["TRAtLeastOneGradeReductionPercent"], 100.0],
      validation["KCCQ change from rounded means", claims["KCCQChangeFromMeans"], 19.1, 0.2],
      <|"Check" -> "KCCQ paired t-test from reported change mean/SD is P < 0.0001", "Actual" -> claims["KCCQPairedTP"], "Expected" -> "< 0.0001", "Tolerance" -> "directional", "Pass" -> TrueQ[claims["KCCQPairedTP"] < 0.0001]|>,
      validation["6MWD paired t-test from reported aggregate", claims["SixMinuteWalkTP"], fun["SixMinuteWalk", "ReportedP"], 0.01],
      validation["all-cause mortality event percentage: 5/37", percent[5, 37], 13.5],
      validation["severe bleeding event percentage: 13/37", percent[13, 37], 35.1],
      validation["heart failure hospitalization percentage: 4/37", percent[4, 37], 10.8],
      validation["count-based survival complements all-cause mortality", claims["SurvivalFromAllCauseMortality"], 86.5],
      validation["KM survival close to count-based survival", claims["ReportedKaplanMeierSurvival"], claims["SurvivalFromAllCauseMortality"], 0.7],
      validation["KM freedom from HF hospitalization close to count complement", claims["ReportedKaplanMeierFreedomFromHFHospitalization"], claims["FreedomFromHFHospitalizationCountBased"], 0.7]
    },
    Map[validation["Table 2 direction: " <> #Parameter, Sign[#DeltaMean], If[MemberQ[{"LVEF by Simpson method"}, #Parameter], 1, -1], 0]& , echo],
    Map[validation["Table 4 percentage: " <> #Event, percent[#Year1Count, 37], #Year1Percent, 0.15]&, mae]
  ]
];

WriteAuditReport[path_String] := Module[{results = RunValidationSuite[], pass, fail, lines},
  pass = Count[results[[All, "Pass"]], True];
  fail = Count[results[[All, "Pass"]], Except[True]];
  lines = Join[
    {
      "Cardioband TR EFS aggregate reproduction audit",
      "Paper: " <> PaperMetadata[]["Title"],
      "Scope: aggregate checks from published tables/figures; patient-level data unavailable.",
      "PASS: " <> ToString[pass] <> "  FAIL: " <> ToString[fail],
      ""
    },
    Map[(If[TrueQ[#Pass], "PASS: ", "FAIL: "] <> #Check <> " | actual=" <> ToString[#Actual, InputForm] <> " expected=" <> ToString[#Expected, InputForm])&, results]
  ];
  Export[path, StringRiffle[lines, "\n"], "Text"];
  results
];

ExportProjectArtifacts[dir_String] := Module[{ann = AnnularDiameterData[], echo = EchoParameterData[], mae = MajorAdverseEventData[], fun = FunctionalOutcomeData[], validation, annPlot, trPlot, maePlot, kccqPlot},
  If[!DirectoryQ[dir], CreateDirectory[dir, CreateIntermediateDirectories -> True]];
  validation = RunValidationSuite[];
  Export[FileNameJoin[{dir, "validation_results.json"}], validation, "JSON"];
  Export[FileNameJoin[{dir, "echo_parameters.csv"}], echo, "CSV"];
  Export[FileNameJoin[{dir, "major_adverse_events.csv"}], mae, "CSV"];
  Export[FileNameJoin[{dir, "annular_diameter.csv"}], ann, "CSV"];
  annPlot = ListLinePlot[ann[[All, "MeanCm"]],
    DataRange -> {1, Length[ann]}, PlotMarkers -> Automatic, PlotTheme -> "Scientific",
    Frame -> True, FrameLabel -> {"Visit", "Mean annular diameter (cm)"},
    PlotLabel -> "Tricuspid annular diameter reduction",
    Epilog -> MapIndexed[Text[#1["Timepoint"], {First[#2], #1["MeanCm"] + 0.08}]&, ann], ImageSize -> 900];
  Export[FileNameJoin[{dir, "figure_annular_diameter.png"}], annPlot];
  trPlot = BarChart[Values[TRGradeOutcomeData[]["OneYearSeverityPercent"]],
    ChartLabels -> Placed[Keys[TRGradeOutcomeData[]["OneYearSeverityPercent"]], Below],
    Frame -> True, FrameLabel -> {"1-year TR grade", "Patients (%)"},
    PlotLabel -> "1-year tricuspid regurgitation severity distribution", ImageSize -> 900];
  Export[FileNameJoin[{dir, "figure_tr_severity_1year.png"}], trPlot];
  kccqPlot = BarChart[{fun["KCCQ", "BaselineMean"], fun["KCCQ", "OneYearMean"]},
    ChartLabels -> {"Baseline", "1 Year"}, Frame -> True, FrameLabel -> {"Visit", "KCCQ score"},
    PlotLabel -> "KCCQ quality-of-life improvement", ImageSize -> 700];
  Export[FileNameJoin[{dir, "figure_kccq.png"}], kccqPlot];
  maePlot = BarChart[mae[[All, "Year1Percent"]],
    ChartLabels -> Placed[mae[[All, "Event"]], Below], ChartStyle -> "SolarColors",
    Frame -> True, FrameLabel -> {"Event", "1-year incidence (%)"},
    PlotLabel -> "CEC-adjudicated events through 1 year", ImageSize -> 1100];
  Export[FileNameJoin[{dir, "figure_major_adverse_events.png"}], maePlot];
  Export[FileNameJoin[{dir, "validation_report.md"}], StringRiffle[Join[
    {"# Validation report", "", "All checks are based on aggregate values transcribed from the paper.", ""},
    Map["- " <> If[TrueQ[#Pass], "PASS", "FAIL"] <> ": " <> #Check&, validation]
  ], "\n"], "Text"];
  validation
];

ExportSimulationArtifacts[dir_String, seed_: 42] := Module[
  {data, summary, follow, trPlot, annPlot, kccqPlot, curvePlot, deathDays, hfDays, n = 37},
  If[!DirectoryQ[dir], CreateDirectory[dir, CreateIntermediateDirectories -> True]];
  data = SimulatePatientDataset[seed];
  summary = SummarizeSimulatedDataset[data];
  follow = Select[data, TrueQ[#HasOneYearEcho]&];
  Export[FileNameJoin[{dir, "synthetic_patient_data.csv"}], data, "CSV"];
  Export[FileNameJoin[{dir, "synthetic_patient_summary.json"}], summary, "JSON"];
  trPlot = BarChart[
    {Counts[follow[[All, "TRGradeBaseline"]]], Counts[follow[[All, "TRGradeOneYear"]]]},
    ChartLabels -> {"Baseline", "1 Year"}, ChartLegends -> Automatic,
    Frame -> True, FrameLabel -> {"Visit", "Synthetic patients"},
    PlotLabel -> "Synthetic patient-level TR grade shift", ImageSize -> 900
  ];
  Export[FileNameJoin[{dir, "simulation_tr_shift.png"}], trPlot];
  annPlot = ListPlot[
    follow[[All, {"AnnularDiameterBaselineMm", "AnnularDiameterOneYearMm"}]],
    Frame -> True, FrameLabel -> {"Baseline annular diameter (mm)", "1-year annular diameter (mm)"},
    PlotLabel -> "Synthetic paired annular diameter response", PlotTheme -> "Scientific", ImageSize -> 800
  ];
  Export[FileNameJoin[{dir, "simulation_annular_scatter.png"}], annPlot];
  kccqPlot = ListPlot[
    follow[[All, {"KCCQBaseline", "KCCQOneYear"}]],
    Frame -> True, FrameLabel -> {"Baseline KCCQ", "1-year KCCQ"},
    PlotLabel -> "Synthetic paired KCCQ response", PlotTheme -> "Scientific", ImageSize -> 800
  ];
  Export[FileNameJoin[{dir, "simulation_kccq_scatter.png"}], kccqPlot];
  SeedRandom[seed + 1000];
  deathDays = Sort[RandomInteger[{45, 365}, 5]];
  hfDays = Sort[RandomInteger[{15, 365}, 4]];
  curvePlot = ListStepPlot[
    {eventCurve[deathDays, n], eventCurve[hfDays, n]},
    Frame -> True, FrameLabel -> {"Days", "Event-free probability"},
    PlotLegends -> {"Synthetic survival", "Synthetic freedom from HF hospitalization"},
    PlotLabel -> "Synthetic event curves constrained to 1-year event counts", ImageSize -> 900
  ];
  Export[FileNameJoin[{dir, "simulation_event_curves.png"}], curvePlot];
  summary
];

End[]
EndPackage[]
