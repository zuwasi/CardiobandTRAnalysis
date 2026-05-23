# Cardioband TR EFS 1-year outcomes: Wolfram reproducibility project

This project analyzes:

> Gray WA et al. **1-Year Outcomes of Cardioband Tricuspid Valve Reconstruction System Early Feasibility Study.** *JACC: Cardiovascular Interventions* 2022;15(19):1921-1932. DOI: `10.1016/j.jcin.2022.07.006`.

Source PDF: `C:\Amp_demos\Edwards\1-s2.0-S1936879822013437-main.pdf`.

## What is reproduced

The paper is a clinical feasibility study, so the Wolfram reproduction focuses on aggregate statistical and graphical checks from the published tables and figures:

- central-illustration annular diameter trajectory and paired 21.3% reduction;
- 1-year TR severity outcomes;
- Table 2 echocardiographic direction-of-change checks;
- Figure 3 NYHA/KCCQ and Table 3 6MWD checks;
- Table 4 major adverse event percentages;
- aggregate consistency checks for Kaplan-Meier survival and freedom from HF hospitalization.

Patient-level data, event times, and censoring data are not available in the PDF, so exact Kaplan-Meier and Wilcoxon reconstruction is out of scope.

## File map

- `src/CardiobandTRModel.wl` - reusable Wolfram package with transcribed aggregate data, recomputation functions, validation suite, and figure/table exporters.
- `CardiobandTRNotebook.nb` - executable notebook-style companion using the package.
- `CardiobandTRSimulationNotebook.nb` - synthetic patient-level demo notebook for interactive exploration. The simulated rows are explicitly labeled and are not real trial data.
- `build_project.wls` - runs validation and exports figures/tables/reports.
- `proof_audit.wls` - paper-specific audit script.
- `docs/plain_english_analysis.md` - claim ledger, audit logic, and limitations.
- `exports/` - generated validation reports, CSVs, and PNG figures.

## Requirements

- WolframScript / Wolfram Language installed and on PATH.
- Tested with the local `wolframscript.exe` installation.

## Run

From PowerShell:

```powershell
Set-Location "C:\Amp_demos\Edwards\CardiobandTRAnalysis"
wolframscript -file .\build_project.wls
wolframscript -file .\proof_audit.wls
```

Generated outputs are written to `exports/`.

The build also creates synthetic demo artifacts:

- `synthetic_patient_data.csv`
- `synthetic_patient_summary.json`
- `simulation_tr_shift.png`
- `simulation_annular_scatter.png`
- `simulation_kccq_scatter.png`
- `simulation_event_curves.png`

## Key limitation

This is an aggregate-data reproducibility project. It validates internal consistency of published counts, percentages, mean changes, and figure values. It cannot replace a patient-level statistical reanalysis.

The simulation notebook is for demonstration and teaching only. It creates plausible patient-level rows constrained to published aggregates, but it must not be interpreted as recovered or deidentified trial data.
