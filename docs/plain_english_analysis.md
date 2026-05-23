# Plain-English analysis companion

## Paper and question

Gray et al. report 1-year outcomes from the Edwards Cardioband Tricuspid Valve Reconstruction System Early Feasibility Study, a prospective, single-arm, multicenter study of 37 patients with at least severe functional or mixed tricuspid regurgitation.

The reproducible question for this Wolfram project is: do the published aggregate tables and figure captions support the paper's headline claims about annular reduction, TR severity reduction, quality-of-life improvement, and 1-year safety outcomes?

## Claim ledger

1. **Annular reduction.** The central illustration reports paired septolateral annular diameter reduction from 44.6 mm to 35.1 mm at 1 year in 24 patients, a 21.3% reduction.
2. **TR severity.** At 1 year, 19 of 26 paired patients had TR at most moderate, 19 of 26 had at least a 2-grade reduction, and all paired 1-year patients improved by at least 1 grade.
3. **KCCQ.** Figure 3 reports KCCQ improvement from 57.3 to 76.4, with paired change 19.0 +/- 19.2 points in 26 patients and P < 0.0001.
4. **6-minute walk.** Table 3 reports mean change 7.2 +/- 132.7 m in 20 patients, P = 0.8112.
5. **Safety.** Table 4 reports all-cause mortality 5/37, cardiovascular mortality 3/37, heart failure hospitalization 4/37, and severe bleeding 13/37 by 1 year.
6. **Kaplan-Meier outputs.** Figure 4 reports survival 85.9% and freedom from heart failure rehospitalization 88.7%. With aggregate counts only, the project verifies these are close to the simple count complements (86.5% and 89.2%); exact Kaplan-Meier reconstruction would require event times and censoring.

## Validation logic

The package recomputes all count-based percentages directly from the published numerators and denominators. It also recomputes approximate paired t-test P values when the paper reports a paired mean change, standard deviation of change, and sample size. This reproduces the non-significant 6MWD result and confirms the KCCQ result is below 0.0001.

## Limitations

Patient-level data are not published in the PDF. Therefore, the project does not claim to exactly reconstruct Wilcoxon signed-rank tests, Kaplan-Meier curves, or paired t-tests whose standard deviations of paired changes are not reported. Those checks are marked as aggregate consistency checks rather than independent patient-level reproductions.

## Bottom line

Within the limits of published aggregate data, the paper's main numeric claims are internally consistent: annular diameter falls by about 21.3%, 1-year TR severity improves substantially, KCCQ change is clinically meaningful and statistically strong, 6MWD is inconclusive, and the reported 1-year event rates match the table counts.
